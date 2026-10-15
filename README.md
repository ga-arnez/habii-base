# habii-base

Harness da Habii Tech para o Claude Code. Este repositório é um **marketplace de plugins** chamado `habii`.

| Plugin | Status | Conteúdo |
|---|---|---|
| `habii-core` | ✅ disponível | Fluxo de trabalho, TDD, entrevista com ADRs, GraphQL (schema e operações), revisor de diff, gate de verificação |
| `habii-ts` | ✅ disponível | TypeScript full-stack: React (performance, composição, design, shadcn, browser), Fastify, Prisma |
| `habii-rails` | 🔜 planejado | Rails + GraphQL, RuboCop, RSpec |
| `habii-mobile` | ✅ disponível | React Native com Expo: performance, testes (RNTL), React Navigation, simulador |

O `habii-core` é agnóstico de stack. Os plugins de stack são usados junto com ele.

## Instalação

```
/plugin marketplace add ga-arnez/habii-base
/plugin install habii-core@habii
/plugin install habii-ts@habii   # projetos TypeScript
/plugin install habii-mobile@habii   # apps Expo
```

Depois ligue o auto-update: `/plugin` → **Marketplaces** → `habii` → **Enable auto-update**. Sem isso, as mudanças só chegam com `/plugin marketplace update habii`.

### Em um projeto

Dentro do repositório do projeto, rode `/habii-core:habii-setup`. A skill cria:

- `CLAUDE.md` enxuto a partir do template;
- `.claude/verify.sh` com o "verde" do projeto (typecheck, lint, testes afetados);
- `.claude/settings.json` registrando o marketplace e ligando os plugins — quem confiar na pasta recebe o convite de instalação automaticamente.

## O que vem no habii-core

**Skills próprias**
- `habii-workflow` — quando planejar, como verificar, quando delegar e quando limpar o contexto.
- `habii-setup` — prepara um projeto (só manual).

**Skills de terceiros** (vendorizadas, ver abaixo)
- `tdd`, `grill-with-docs` (+ `grilling` e `domain-modeling`, das quais ele depende) — mattpocock/skills
- `graphql-schema` e `graphql-operations` — apollographql/skills: desenho de schema e escrita de operações, valem para web, mobile e Rails

**Agents**
- `reviewer` — revisa o diff em contexto limpo contra o SPEC; só corretude e requisitos.
- `explorer` — exploração somente leitura com Haiku, para não poluir o contexto principal.

**Hook Stop**
Roda `.claude/verify.sh` do projeto antes de o Claude encerrar o turno, se houver mudanças. Falhou → o Claude recebe o erro e continua corrigindo. Desligar pontualmente: `HABII_SKIP_VERIFY=1`.

## O que vem no habii-ts

Só skills de terceiros (vendorizadas):
- **React:** `vercel-react-best-practices`, `vercel-composition-patterns`, `web-design-guidelines` — vercel-labs/agent-skills
- **UI:** `frontend-design` — anthropics/skills; `shadcn` — shadcn-ui/ui
- **Browser:** `agent-browser` — vercel-labs/agent-browser (requer o binário `agent-browser` instalado)
- **GraphQL:** `apollo-client` (Apollo Client 4.x) — apollographql/skills
- **Backend:** `fastify-best-practices` — mcollina/skills; `prisma-client-api` e `prisma-cli` (Prisma 7) — prisma/skills

tRPC e TanStack Query **não** são vendorizados: as skills vêm dentro dos pacotes npm, na versão instalada. O `habii-setup` roda `npx @tanstack/intent@latest install` quando o projeto usa essas libs.

## O que vem no habii-mobile

Só skills de terceiros (vendorizadas):
- `react-native-best-practices` e `react-navigation` — callstackincubator/agent-skills
- `react-native-testing` (React Native Testing Library) — callstack/react-native-testing-library
- `apollo-client` (Apollo Client 4.x) — apollographql/skills
- `agent-device` — callstackincubator/agent-device: controla simulador iOS/Android para o Claude provar a mudança (requer o binário `agent-device` instalado)

As skills oficiais da Expo (Router, EAS, upgrade, UI nativa…) **não** são vendorizadas: o `habii-setup` registra o marketplace `expo-plugins` (expo/skills) e liga o plugin `expo`, mantido pela própria Expo. Ele também traz o MCP `mcp.expo.dev`, que pede login na conta Expo.

## Skills de terceiros

As skills são **copiadas** para dentro do plugin (não há vínculo vivo com o upstream).

- Lista: `vendor/skills.txt` (`<plugin>[,<plugin>...] <repo> <skill>` — o(s) plugin(s) de destino de cada skill)
- Origem e hash de cada uma: `vendor/skills-lock.json`
- Atualizar manualmente: `./scripts/sync-vendor.sh`, revisar o diff e commitar.
- Automático: o workflow `Sync vendored skills` roda toda segunda e **abre um PR** com as mudanças. Revise antes de mergear — essas instruções passam a valer para todo mundo.

> Para o workflow conseguir abrir PRs: *Settings → Actions → General → Workflow permissions* → marque **Allow GitHub Actions to create and approve pull requests**.

## Versionamento

Os plugins **não** declaram `version`: quem tem auto-update ligado recebe cada commit da `main`. Se um dia precisar segurar uma versão, adicione `version` ao `plugin.json` e passe a subir o número a cada release.

Os nomes dos plugins são identificadores. Não renomeie; se for inevitável, use o mapa `renames` no `marketplace.json`.

## Validar

```
claude plugin validate .
```
