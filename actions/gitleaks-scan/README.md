<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/gitleaks-scan" version="<sha-completo>" -->
# Gitleaks scan

## Description

Scan committed HEAD content for secrets with a verified Gitleaks binary

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `config` | <p>Optional workspace-relative Gitleaks config path</p> | `false` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/gitleaks-scan@<sha-completo>
  with:
    config:
    # Optional workspace-relative Gitleaks config path
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/gitleaks-scan" version="<sha-completo>" -->

<!-- END_DOCS -->

## 1. Exemplo de job

Troque `<sha-completo>` pelo SHA de 40 caracteres de uma versão publicada deste repositório.

```yaml
name: Secret scan

on:
  pull_request:
  push:

permissions: {}

jobs:
  scan:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      contents: read
    steps:
    - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1  # v7.0.1
      with:
        persist-credentials: false
    - uses: lpsm-dev/reusable-workflows/actions/gitleaks-scan@<sha-completo>
```

## 2. Configuração e resultado

Sem `config`, a action usa `.github/config/.gitleaks.toml` se o arquivo existir. Caso contrário, o Gitleaks procura `.gitleaks.toml` no conteúdo de `HEAD` e depois usa as regras padrão. Um caminho explícito deve apontar para um arquivo dentro do workspace. A action falha quando encontra um segredo e mascara o valor no log.
