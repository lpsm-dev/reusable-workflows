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

<!-- END_DOCS -->
