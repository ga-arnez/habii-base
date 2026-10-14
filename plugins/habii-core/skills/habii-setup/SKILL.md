---
name: habii-setup
description: Prepara um repositório de projeto para o harness Habii — cria CLAUDE.md enxuto, .claude/verify.sh e registra o marketplace habii no .claude/settings.json. Use só quando o usuário pedir para configurar o projeto.
disable-model-invocation: true
---

# Setup de projeto Habii

Prepare o repositório atual em quatro passos. Não sobrescreva nada que já exista sem perguntar; quando um arquivo existir, proponha o diff.

## 1. Descubra a stack
Inspecione a raiz: `turbo.json`/`pnpm-workspace.yaml` (Turborepo/TS), `Gemfile` com `rails` (Rails), `app.json`/`expo` no `package.json` (React Native). Descubra os comandos reais de typecheck, lint e teste lendo `package.json`, `turbo.json`, `Gemfile`, `bin/`.

## 2. CLAUDE.md
Se não existir, crie a partir de `templates/CLAUDE.md` (nesta pasta da skill) preenchendo com o que você **verificou** no passo 1. Regras:
- Menos de 200 linhas; ideal menos de 80.
- Só o que o Claude não descobre lendo o código: comandos, peculiaridades de ambiente, decisões de arquitetura locais, armadilhas.
- Nada de descrever arquivo por arquivo nem convenções óbvias da linguagem.
- Notas para humanos em comentários HTML (`<!-- -->`), que não chegam ao contexto.

## 3. .claude/verify.sh
Crie a partir de `templates/verify.sh`, com os comandos verificados no passo 1, e `chmod +x`. É o "verde" do projeto: o hook Stop do habii-core o roda antes de o Claude encerrar. Deve ser **rápido** (segundos, não minutos): typecheck e lint do que mudou e testes unitários afetados; deixe e2e para o CI.

Rode o script uma vez. Se o projeto já estiver vermelho (legado), avise o usuário e combine: corrigir antes, ou começar com um verify.sh mais estreito.

## 4. .claude/settings.json
Garanta (fazendo merge com o que existir) as entradas de `templates/settings.json`, ligando em `enabledPlugins` só os plugins da stack detectada que já existirem no marketplace (hoje: `habii-core`).

## Ao terminar
Liste os arquivos criados/alterados e a saída da primeira execução do `verify.sh`. Lembre o usuário de commitar o `.claude/settings.json` e o `CLAUDE.md`, e de ligar o auto-update do marketplace em `/plugin` → Marketplaces.
