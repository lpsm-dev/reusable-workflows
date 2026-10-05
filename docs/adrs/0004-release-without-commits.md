---
status: accepted
date: 2026-10-05
---

# Release sem commit na main e ruleset na main

## Contexto

O `_release.yaml` rodava o semantic-release com `@semantic-release/changelog` e `@semantic-release/git`, que fazem commit do `CHANGELOG.md` e do `README.md` direto na `main` com o `GITHUB_TOKEN`. A `main` não tinha proteção nem ruleset, então qualquer push chegava nela sem pull request nem CI (CICD-SEC-1).

Um ruleset que exige pull request bloqueia esse commit do release. Liberar o bot do Actions no ruleset deixaria qualquer workflow com permissão de escrita empurrar código na `main`, que é o cenário que o CICD-SEC-1 e o CICD-SEC-4 tentam evitar.

## Decisão

- O release cria só a tag e o GitHub Release com as notas da versão. Saem `@semantic-release/changelog` e `@semantic-release/git`, e o `CHANGELOG.md` fica como histórico até a versão 1.0.0.
- A `main` ganha um ruleset sem exceção para ninguém: pull request obrigatório com merge por squash; os checks `scan / scan`, `Action Lint` e `YAML Lint`, emitidos pelo GitHub Actions, verdes e com a branch atualizada; force push e exclusão bloqueados.
- O ruleset não exige aprovação, porque o repositório tem um mantenedor só e ninguém aprova o próprio pull request.
- O token padrão do repositório passa a ser só leitura. Cada workflow declara as permissões de que precisa.

## Opções consideradas

- **A (escolhida): release sem commit e ruleset completo.** A `main` só muda por pull request com CI verde.
- **B (rejeitada): bypass do bot do Actions no ruleset.** Qualquer workflow com escrita passaria a poder alterar a `main`.
- **C (rejeitada): ruleset parcial, só contra force push e exclusão.** Mantém o release igual, mas push direto continua possível.
- **D (rejeitada): GitHub App próprio com bypass para manter o commit do changelog.** Exige uma chave privada de longa duração e mais infraestrutura para manter um arquivo que o GitHub Release já cobre.

## Consequências

- As notas de versão passam a ficar nos GitHub Releases.
- Todo workflow que precisar alterar a `main` tem que abrir um pull request.
- Com todas as actions fixadas por SHA, a opção `sha_pinning_required` pode ser ligada nas configurações do repositório.
