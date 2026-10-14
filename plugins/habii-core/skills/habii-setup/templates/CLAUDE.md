# <Nome do projeto>

<!-- Template Habii. Mantenha abaixo de 80 linhas. Para cada linha, pergunte:
     "removê-la faria o Claude errar?" Se não, corte. Comentários como este não chegam ao contexto. -->

<Uma frase: o que o sistema faz e para quem.>

## Comandos
- Instalar: `<comando>`
- Dev: `<comando>`
- Typecheck: `<comando>`
- Lint: `<comando>`
- Teste de um arquivo: `<comando> <caminho>`
- Verificação completa: `.claude/verify.sh`

## Arquitetura
<!-- Só decisões locais que não aparecem lendo o código. Decisões maiores vão em docs/adr/. -->
- <ex.: apps/api é Fastify + Zod; contratos compartilhados em packages/contracts>
- <ex.: toda integração externa passa por packages/integrations; nunca chamar direto do app>

## Armadilhas
- <ex.: variáveis de ambiente exigidas: DATABASE_URL, FOCUS_NFE_TOKEN>
- <ex.: migrations Prisma só via `pnpm db:migrate`, nunca `prisma db push` em staging>

## Ao compactar
Preserve a lista de arquivos modificados e os comandos de teste usados.
