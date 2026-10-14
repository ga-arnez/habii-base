# habii-base

Harness da Habii Tech para o Claude Code. Este repositório é um **marketplace de plugins** chamado `habii`.

| Plugin | Status | Conteúdo |
|---|---|---|
| `habii-core` | ✅ disponível | Fluxo de trabalho, TDD, entrevista com ADRs, revisor de diff, gate de verificação |
| `habii-ts` | 🔜 planejado | Turborepo, tRPC + Zod, Prisma, Fastify, hooks de typecheck, LSP de TypeScript |
| `habii-rails` | 🔜 planejado | Rails + GraphQL, RuboCop, RSpec |
| `habii-rn` | 🔜 planejado | React Native / Expo |

O `habii-core` é agnóstico de stack. Os plugins de stack vão depender dele.

## Instalação

```
/plugin marketplace add ga-arnez/habii-base
/plugin install habii-core@habii
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
- `frontend-design` — anthropics/skills
- `agent-browser` — vercel-labs/agent-browser (requer o binário `agent-browser` instalado)
- `token-efficiency` — delphine-l/claude_global

**Agents**
- `reviewer` — revisa o diff em contexto limpo contra o SPEC; só corretude e requisitos.
- `explorer` — exploração somente leitura com Haiku, para não poluir o contexto principal.

**Hook Stop**
Roda `.claude/verify.sh` do projeto antes de o Claude encerrar o turno, se houver mudanças. Falhou → o Claude recebe o erro e continua corrigindo. Desligar pontualmente: `HABII_SKIP_VERIFY=1`.

## Skills de terceiros

As skills são **copiadas** para dentro do plugin (não há vínculo vivo com o upstream).

- Lista: `vendor/skills.txt`
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
