---
name: habii-rails
description: Habii Tech conventions for Rails backends with graphql-ruby and Doorkeeper — schemas per audience, mutations returning errors, business logic in app/actions (application_action), search_object resolvers, uploads, soft delete and RSpec specs (criar mutation, query, action, resolver, spec no Rails). Use when adding or changing anything under app/graphql, app/actions, app/models or spec in a Rails project.
---

# Habii Rails conventions

Habii backends share one shape: Rails + PostgreSQL, a GraphQL API for the apps (graphql-ruby), Devise + Doorkeeper OAuth, an ERB/Hotwire admin, RSpec + FactoryBot + FFaker. Before writing code, open the closest existing file of the same kind and mirror it; the project's CLAUDE.md wins over this skill when they differ.

Versions vary (Rails 6.1 to 8.1). Check `Gemfile.lock` before using newer syntax (e.g. `{ user: }` shorthand needs Ruby 3.1+; Solid Queue vs GoodJob for jobs).

## Schemas per audience

Each audience has its own schema, controller and context. Never add a field to the wrong schema.

| Schema | Route | Auth | Context |
|---|---|---|---|
| `PublicSchema` | `POST /graphql` | none / client credentials | — |
| `UserSchema` (or `CompanyUserSchema`, `CompanyAdminSchema`…) | `POST /user/graphql` | Doorkeeper bearer token | `context[:current_user]` (or `current_company_user`…) |

- Entry points: `app/graphql/types/<audience>/{query_type,mutation_type}.rb`; shared object types in `app/graphql/types/models/`, inputs in `types/input(s)/`, enums in `types/enums/`.
- Mutations live in `app/graphql/mutations/<audience>_mutations/` (public ones in `mutations/public/`).
- The controller defines `schema` and `context` and includes the GraphQL controller mixin (`DevmakerRailsSdk::GraphqlControllerMixin` or a local `GraphqlControllerMixin`).
- Login is a public mutation that validates the Doorkeeper app (`client_id`/`client_secret`) and returns a token (`HandleLoginMutationMixin`). The apps also call `POST /oauth/token` directly.

## Mutations

Mutations are thin: parse arguments, scope through the current user, delegate to an action or a single `save`, and return **either the resource or `errors`**. The clients rely on this shape — never raise for validation failures.

```ruby
module Mutations
  module UserMutations
    class UpdateThingMutation < Mutations::BaseMutation   # RelayClassicMutation → clients send `input:`
      include DevmakerRailsSdk::ErrorHandlingMutationMixin  # or Mutations::Mixins::ErrorHandlingMutation

      argument :id, ID, required: true
      argument :name, String, required: false
      argument :file, Types::Scalars::UploadType, required: false  # or DevmakerRailsSdk::Types::Scalars::UploadType

      field :thing, Types::Models::ThingType, null: true
      field :errors, [String], null: true

      def resolve(id:, **attrs)
        thing = context[:current_user].things.kept.find_by(id:)   # scope via the user, never Thing.find
        return not_found_error("Thing", id) unless thing

        thing.assign_attributes(attrs)
        save_and_handle_errors_of(:thing, thing)
      end
    end
  end
end
```

- Use the error mixin the project already has (`save_and_handle_errors_of`, `destroy_and_handle_errors_of`, `not_found_error`). Do not create a third variant.
- `errors` are human-readable messages in **pt-BR** (`record.errors.full_messages`, `I18n.t`), shown as-is by the apps.
- Register the mutation in the audience's `mutation_type.rb`.

## Actions (business logic)

Anything beyond a single `save` goes to `app/actions/` as an `ApplicationAction` (gem `application_action`). Mutations, controllers and jobs call actions; actions may call other actions.

```ruby
class FinishThing < ApplicationAction
  attr_accessor :user, :thing_id

  validates :user, :thing, presence: true
  validate :thing_must_be_open, if: -> { errors.blank? }

  def run          # runs inside .save, only if valid
    thing.update!(finished_at: Time.current)
  end

  def after_run    # side effects: notifications, pushes
    Notifications::ThingFinished.new(thing:).save
  end

  def thing
    @thing ||= user&.things&.kept&.find_by(id: thing_id)
  end

  private

  def thing_must_be_open
    errors.add(:base, "Item já finalizado") if thing.finished_at?
  end
end

# in the mutation
action = FinishThing.new(user: context[:current_user], thing_id: id)
action.save ? { thing: action.thing } : { errors: action.errors.full_messages }
```

- Expose results through reader methods; callers read them after `save`.
- Scheduled logic: `app/actions/cron/`, invoked by a job in `app/jobs/`.
- `app/services/` is for technical helpers (image optimization, API clients), not business rules.

## Queries and resolvers

- Lists use resolvers extending `Resolvers::BaseSearchResolver` (`search_object_graphql`) in `app/graphql/resolvers/`:
  - `type Types::Models::ThingType.connection_type` for cursor pagination (or the project's page-based concern);
  - `scope { ... }` and `new_empty_search` return the same base relation;
  - filters are an input object with an `OR: [self]` argument, wired by `option :where, type: ..., with: :apply_conditions`; each filter key `foo` is handled by a `foo_condition(scope, value)` method.
- Always start the scope from the authenticated user / tenant (`Company`). Unscoped `Model.all` in a non-admin schema is a data leak.

## Models

- Soft delete with `Discard::Model`: query `.kept`, call `discard`, not `destroy`, unless the model has no `discarded_at`.
- Integer enums: **only append** new values; reordering changes existing rows.
- Brazilian documents: validate CPF/CNPJ with the `cpf_cnpj` gem and normalize to digits in `before_validation`.
- Admin CRUDs are usually generated with `bin/rails g devmaker_rails_sdk:crud Model field:type` when the project uses `devmaker_rails_sdk`; follow the generated structure.

## Specs

RSpec + FactoryBot (`spec/factories/`) + FFaker. Most projects call `FactoryBot.create` explicitly; use bare `create` only if `spec/support` includes `FactoryBot::Syntax::Methods`. Mirror the existing folder layout: `spec/actions/`, `spec/graphql/<audience>/{queries,mutations}/`, `spec/models/`.

GraphQL specs execute the schema directly with the same context the controller builds:

```ruby
RSpec.describe "updateThing mutation" do
  let(:user) { FactoryBot.create(:user) }
  let(:thing) { FactoryBot.create(:thing, user:) }
  let(:query) do
    <<~GQL
      mutation($input: UpdateThingMutationInput!) {
        updateThing(input: $input) { thing { id name } errors }
      }
    GQL
  end

  def execute(input, current_user: user)
    UserSchema.execute(query, variables: { input: }, context: { current_user: }).to_h
  end

  it "updates the user's thing" do
    result = execute({ id: thing.id, name: "Novo" })
    expect(result.dig("data", "updateThing", "errors")).to be_nil
    expect(thing.reload.name).to eq("Novo")
  end

  it "does not touch another user's thing" do
    result = execute({ id: FactoryBot.create(:thing).id, name: "x" })
    expect(result.dig("data", "updateThing", "errors")).to be_present
  end
end
```

Every mutation/query on a scoped schema needs the "another user/tenant" case. Run a single file with `bundle exec rspec path/to/file_spec.rb:LINE`.

## After changing the schema

Field, argument or type changes break the apps' generated types. Tell the user which client repos must run `yarn codegen` and whether the change is breaking (removed/renamed field, nullable → non-null argument). Prefer adding fields and deprecating (`deprecation_reason:`) over renaming.
