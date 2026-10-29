<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

Após o checkout, valide o YAML com a configuração do projeto:

```yaml
- uses: lpsm-dev/reusable-workflows/actions/yamllint-check@56f5dbe1a8091b2c2dea19516375689aa9d0f017
  with:
    target: .
    config: .github/config/.yamllint.yaml
```

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/yamllint-check" version="<sha-completo>" -->
# Yamllint check

## Description

Validate YAML files with a pinned, hash-locked yamllint environment

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `target` | <p>File or directory to validate, relative to the caller workspace</p> | `false` | `.` |
| `config` | <p>Optional yamllint configuration, relative to the caller workspace</p> | `false` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/yamllint-check@<sha-completo>
  with:
    target:
    # File or directory to validate, relative to the caller workspace
    #
    # Required: false
    # Default: .

    config:
    # Optional yamllint configuration, relative to the caller workspace
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/yamllint-check" version="<sha-completo>" -->

<!-- END_DOCS -->
