<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/commitlint-check" version="<sha-completo>" -->
# Commitlint check

## Description

Validate Conventional Commits with a locked commitlint toolchain

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `base-sha` | <p>Optional first commit (excluded) for range validation</p> | `false` | `""` |
| `head-sha` | <p>Optional last commit (included) for range validation</p> | `false` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/commitlint-check@<sha-completo>
  with:
    base-sha:
    # Optional first commit (excluded) for range validation
    #
    # Required: false
    # Default: ""

    head-sha:
    # Optional last commit (included) for range validation
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/commitlint-check" version="<sha-completo>" -->

## 1. Exemplo com intervalo de commits

O job que chama faz checkout com histórico completo e passa o primeiro e o último SHA do intervalo. Os dois inputs devem ser SHA completos. Sem eles, a action valida a mensagem do `HEAD`.

```yaml
jobs:
  commits:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      contents: read
    steps:
    - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1  # v7.0.1
      with:
        fetch-depth: 0
        persist-credentials: false
    - uses: lpsm-dev/reusable-workflows/actions/commitlint-check@44b9f3732d9b0b99bdf9cb0f0be97c89e250b0c5
      with:
        base-sha: ${{ github.event.pull_request.base.sha }}
        head-sha: ${{ github.event.pull_request.head.sha }}
```

O commitlint e o preset convencional ficam no lockfile desta action. A instalação usa `npm ci --ignore-scripts`. O job precisa de rede para obter os pacotes do npm.

<!-- END_DOCS -->
