<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/semantic-release-run" version="<sha-completo>" -->
# Semantic Release run

## Description

Run semantic-release from the caller's locked configuration

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `release-directory` | <p>Workspace-relative directory with package.json, package-lock.json and .releaserc.json</p> | `false` | `.github/config/release` |
| `release-branch` | <p>Branch permitted to publish a release</p> | `false` | `main` |
| `dry-run` | <p>Analyze and verify a release without publishing it</p> | `false` | `false` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/semantic-release-run@<sha-completo>
  with:
    release-directory:
    # Workspace-relative directory with package.json, package-lock.json and .releaserc.json
    #
    # Required: false
    # Default: .github/config/release

    release-branch:
    # Branch permitted to publish a release
    #
    # Required: false
    # Default: main

    dry-run:
    # Analyze and verify a release without publishing it
    #
    # Required: false
    # Default: false
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/semantic-release-run" version="<sha-completo>" -->

<!-- END_DOCS -->

## 1. Exemplo de job

Crie `package.json`, `package-lock.json` e `.releaserc.json` em `.github/config/release/` no projeto consumidor. O exemplo fixa o SHA completo de uma versão publicada deste repositório.

```yaml
name: Release

on:
  workflow_dispatch:

permissions: {}

jobs:
  release:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
    - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1  # v7.0.1
      with:
        fetch-depth: 0
        persist-credentials: false
    - uses: lpsm-dev/reusable-workflows/actions/semantic-release-run@448df7be7d80aafadc6e0db77bc577c031cd0bca
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 2. Publicação e simulação

O lockfile do consumidor define as versões da ferramenta e dos plugins. A action executa `npm ci --ignore-scripts --no-audit --no-fund` nesse diretório. A publicação exige a branch indicada em `release-branch`; `dry-run: 'true'` permite verificar outra branch sem publicar. O token chega pelo ambiente do step e precisa das permissões do job.
