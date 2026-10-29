---
date: 2026-10-29
---

# Reusable workflow do semantic-release

## 1. O que é

O [`semantic-release.yaml`](../../../.github/workflows/semantic-release.yaml) transforma commits convencionais em uma versão. O job roda apenas na branch indicada e pode executar em modo de simulação. O projeto que chama controla suas regras de versão e seus plugins por meio de uma configuração e de um lockfile próprios.

O workflow prepara o job e chama a action [`semantic-release-run`](../../../actions/semantic-release-run/README.md). Quem controla o próprio job pode chamar a action diretamente.

Neste repositório, o workflow manual [`_release.yaml`](../../../.github/workflows/_release.yaml) chama esse mesmo job. Sua configuração cria somente a tag e o GitHub Release, conforme o [adr-003](../../adrs/adr-003-release-without-commits.md).

## 2. Como as peças se ligam

### 2.1. Prepare a configuração

Crie `.github/config/release/` no projeto que chama, com `package.json`, `package-lock.json` e `.releaserc.json`. Trave as versões diretas em `package.json` e atualize o lockfile com `npm install --package-lock-only`. A action instala o conjunto com `npm ci --ignore-scripts`.

A configuração decide quais plugins publicam o resultado. Para criar apenas tag e GitHub Release, use o analisador de commits, o gerador de notas e `@semantic-release/github`. Não inclua plugins que gravam commits ou publicam pacotes se esse não for o objetivo do projeto.

### 2.2. Chame o workflow

```yaml
name: Release

on:
  workflow_dispatch:

permissions: {}

jobs:
  release:
    uses: lpsm-dev/reusable-workflows/.github/workflows/semantic-release.yaml@56f5dbe1a8091b2c2dea19516375689aa9d0f017
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

O workflow não declara secrets próprios nem outputs. Ele passa o `GITHUB_TOKEN` do job à action. Se a branch atual não for `release-branch`, o job é ignorado. Se faltar algum dos três arquivos de configuração, o job falha antes de executar o semantic-release.

### 2.4. Verifique antes de publicar

Passe `dry-run: true` em uma chamada na branch de release para conferir a próxima versão e as permissões. A simulação não cria tag nem GitHub Release. Ela ainda precisa consultar a API do GitHub e verificar acesso ao repositório.

### 2.5. Uso como action

Use a [action de semantic-release](../../../actions/semantic-release-run/README.md#1-exemplo-de-job) quando o job precisar de outros steps. Faça checkout com `fetch-depth: 0`, passe `GITHUB_TOKEN` pelo ambiente e conceda as permissões de release ao job. A action falha se tentar publicar fora da `release-branch`; `dry-run: 'true'` pode rodar em outra branch.

## 3. Para onde seguir

- [Catálogo de workflows e actions](../../../README.md#3-catálogo).
- [Release sem commit na branch principal](../../adrs/adr-003-release-without-commits.md).
- [Como adicionar um reusable workflow](../../../CONTRIBUTING.md#31-reusable-workflow).
