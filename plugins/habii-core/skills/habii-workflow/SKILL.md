---
name: habii-workflow
description: Fluxo de trabalho padrão da Habii Tech para implementar features, corrigir bugs e refatorar — quando planejar, como verificar, quando delegar a subagentes e quando limpar o contexto. Use ao iniciar qualquer tarefa de código que mexa em mais de um arquivo.
---

# Fluxo de trabalho Habii

O recurso mais caro é o contexto. Tudo aqui serve para mantê-lo pequeno e verificável.

## 1. Dimensione a tarefa
- **Dá para descrever o diff numa frase?** Faça direto, sem plano.
- **Abordagem incerta, vários arquivos ou código desconhecido?** Explore e planeje antes (plan mode).
- **Feature grande ou requisito ambíguo?** Use `grill-with-docs` para entrevistar o usuário, registre decisões em ADR e escreva um `SPEC.md`. Implemente numa sessão nova, partindo do SPEC.

## 2. Explore sem poluir o contexto
- Leitura ampla (muitos arquivos, logs, histórico) → delegue ao subagente `explorer` e trabalhe com o mapa que ele devolve.
- Antes de criar algo, procure o padrão existente mais próximo no projeto e siga-o.
- Leia `GLOSSARY.md` e ADRs em `docs/adr/` quando existirem; use o vocabulário do domínio.

## 3. Implemente contra uma verificação
- Defina antes como saber que funcionou: teste, typecheck, build, screenshot.
- Comportamento novo ou bug → `tdd`: teste falhando primeiro, depois a correção.
- O projeto pode ter `.claude/verify.sh`; o hook Stop o roda e bloqueia o encerramento se falhar. Corrija a causa raiz — nunca desative checagem, nunca use `any`/`@ts-ignore`/`skip` para passar.

## 4. Prove, não afirme
Ao concluir, mostre a evidência: o comando que rodou e o resultado. "Deve funcionar" não é conclusão.

## 5. Revise em contexto limpo
Mudança relevante → subagente `reviewer` contra o SPEC/plano. Corrija só o que afeta corretude ou requisitos; trate o resto como opcional.

## 6. Higiene de sessão
- Corrigiu a mesma coisa duas vezes e ainda está errado? Pare, resuma o que aprendeu e sugira `/clear` com um prompt melhor.
- Tarefas não relacionadas → sessões separadas.
- Prefira CLIs (`gh`, `turbo`, `pnpm`, `bin/rails`) a MCPs quando ambos servem.
