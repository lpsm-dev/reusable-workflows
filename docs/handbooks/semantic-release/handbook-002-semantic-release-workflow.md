---
date: 2026-10-29
---

# Reusable workflow do semantic-release

## 1. O que é

O [`semantic-release.yaml`](../../../.github/workflows/semantic-release.yaml) transforma commits convencionais em uma versão. O job roda apenas na branch indicada e pode executar em modo de simulação. O projeto que chama controla suas regras de versão e seus plugins por meio de uma configuração e de um lockfile próprios.

Neste repositório, o workflow manual [`_release.yaml`](../../../.github/workflows/_release.yaml) chama esse mesmo job. Sua configuração cria somente a tag e o GitHub Release, conforme o [adr-003](../../adrs/adr-003-release-without-commits.md).

## 2. Como as peças se ligam

### 2.1. Prepare a configuração

Crie `.github/config/release/` no projeto que chama, com `package.json`, `package-lock.json` e `.releaserc.json`. Trave as versões diretas em `package.json` e atualize o lockfile com `npm install --package-lock-only`. O workflow instala o conjunto com `npm ci --ignore-scripts`.

A configuração decide quais plugins publicam o resultado. Para criar apenas tag e GitHub Release, use o analisador de commits, o gerador de notas e `@semantic-release/github`. Não inclua plugins que gravam commits ou publicam pacotes se esse não for o objetivo do projeto.

### 2.2. Chame o workflow

```yaml
name: Release

on:
  workflow_dispatch:

permissions: {}

jobs:
  release:
    uses: lpsm-dev/reusable-workflows/.github/workflows/semantic-release.yaml@5e7fedf8658c85586bb4553953890e4cbf72a481
    permissions:
      contents: write
      issues: write
      pull-requests: write
```

O exemplo usa o SHA completo de um commit que contém o workflow. O token precisa das permissões declaradas no job. A execução normal pode criar uma tag e um GitHub Release no repositório que chama.

### 2.3. Entradas

| Nome | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `release-directory` | `string` | `.github/config/release` | Diretório da configuração dentro do workspace |
| `release-branch` | `string` | `main` | Branch autorizada a executar o job |
| `dry-run` | `boolean` | `false` | Analisa e verifica o release sem publicar |

O workflow não declara secrets próprios nem outputs. Ele usa o `GITHUB_TOKEN` do job que chama. Se a branch atual não for `release-branch`, o job é ignorado. Se faltar algum dos três arquivos de configuração, o job falha antes de executar o semantic-release.

### 2.4. Verifique antes de publicar

Passe `dry-run: true` em uma chamada na branch de release para conferir a próxima versão e as permissões. A simulação não cria tag nem GitHub Release. Ela ainda precisa consultar a API do GitHub e verificar acesso ao repositório.

## 3. Para onde seguir

- [Catálogo de workflows e actions](../../../README.md#3-catálogo).
- [Release sem commit na branch principal](../../adrs/adr-003-release-without-commits.md).
- [Como adicionar um reusable workflow](../../../CONTRIBUTING.md#31-reusable-workflow).
