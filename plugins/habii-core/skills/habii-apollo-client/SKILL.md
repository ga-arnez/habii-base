---
name: habii-apollo-client
description: Habii Tech's Apollo Client setup for React web and Expo apps talking to the Rails GraphQL API — endpoint per auth state, link chain, upload, `errors` field handling, codegen hooks; covers Apollo Client 3.x and 4.x (configurar Apollo, chamar mutation, tratar errors, rodar codegen). Use when touching @apollo/client setup, .graphql operation files, generated hooks or mutation error handling.
---

# Habii Apollo Client

The apps talk to a Rails GraphQL API (see `habii-rails`) with one schema per audience. Mirror the project's existing `use-apollo-service` hook and `.graphql` files before writing new code.

## Check the version first

Most projects are on **Apollo Client 3.x**; a few are on **4.x**. Read `@apollo/client` in `package.json` and use the matching API — they are not interchangeable:

| | 3.x | 4.x |
|---|---|---|
| Error link | `onError(({ graphQLErrors, networkError }) => …)` | `new ErrorLink(({ error }) => …)` + `CombinedGraphQLErrors.is(error)` |
| Mapping a response in a link | `forward(operation).map(fn)` | `forward(operation).pipe(map(fn))` (rxjs) |
| Upload link | `createUploadLink` from `apollo-upload-client/createUploadLink.mjs` (v17/18) | `new UploadHttpLink` from `apollo-upload-client/UploadHttpLink.mjs` (v19) |
| React hooks import | `@apollo/client` | `@apollo/client/react` |
| Client type | `ApolloClient<NormalizedCacheObject>` | `ApolloClient` (no generic) |

Do not upgrade Apollo as a side effect of another task.

## Client setup (`hooks/use-apollo-service`)

- **Endpoint follows auth state:** unauthenticated → `${API_URL}/graphql.json`; authenticated → `${API_URL}/<audience>/graphql.json` (`/user`, `/company_user`…). Rebuild the client in `useMemo` when the token/user changes.
- **Link order:** `errorLink → errorsFieldLink → authLink → uploadLink`.
  - `errorLink`: 401/403 → toast + `logout()`; other GraphQL/network errors → generic translated toast.
  - `authLink`: `setContext` adding `Authorization: Bearer <accessToken>`.
  - `uploadLink`: on React Native set `isExtractableFile: (v) => v instanceof ReactNativeFile`.
- Default fetch policies: `watchQuery: cache-and-network`, `query: network-only`.
- Keep callbacks used inside links (toast, `t`, `logout`) in refs so the client is not rebuilt on every render.

### The `errors` field link

Rails mutations return `{ <resource>, errors: [String] }` instead of GraphQL errors. The link that surfaces them must read **the root fields of `response.data`**, not `data[operation.operationName]` — operation names (`mutation TestCheckIn { checkIn … }`) usually differ from the root field, and then the link silently does nothing.

```ts
const errorsFieldLink = new ApolloLink((operation, forward) =>
  forward(operation).map((response) => {          // 4.x: .pipe(map(...))
    Object.values(response.data ?? {}).forEach((payload) => {
      const errors = (payload as { errors?: unknown } | null)?.errors;
      if (Array.isArray(errors)) {
        errors.forEach((e) => typeof e === "string" && toastRef.current({ type: "error", description: e }));
      }
    });
    return response;
  }),
);
```

If a screen already shows `data.<field>.errors[0]` itself, don't also toast from the link for that operation — pick one place per project and follow it.

## Operations and codegen

- Operations live in `graphql/` (`queries/`, `mutations/`, `fragments/` in newer projects) as `.graphql` files. Name the operation after its root field (`mutation checkIn { checkIn(...) }`) and always select `errors` on mutations.
- Never write `gql` strings in components; use the hooks generated into `__generated__/graphql.tsx` (`useCheckInMutation`, …). Never edit generated files.
- After adding or changing an operation, or after a backend schema change, run `yarn codegen`. `codegen.ts` reads `CODEGEN_API_URL` and bearer tokens from `.env` and introspects both the public and the authenticated endpoints; if those env vars are missing, ask the user instead of hand-writing types.
- Scalars: `ISO8601Date`/`ISO8601DateTime` → `string`, `Upload`/`UploadData` → `File`.

## Calling mutations

```ts
const [checkIn, { loading }] = useCheckInMutation();

const onSubmit = async (values: FormValues) => {        // async + awaited: react-hook-form tracks isSubmitting
  const { data } = await checkIn({ variables: { input: values } });  // RelayClassicMutation → `input`
  if (data?.checkIn?.errors?.length) return;            // already toasted by errorsFieldLink (or show errors[0])
  showToast({ type: "success", description: t("success") });
};
```

- Handle loading, error and empty states in every screen that queries.
- User-facing strings go through i18n (`useI18n(keyPrefix)`, pt-BR); messages in `errors` come translated from the backend and are shown as-is.
