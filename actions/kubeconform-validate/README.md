<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/kubeconform-validate" version="<sha-completo>" -->
# Kubeconform Validate

## Description

Validate rendered Kubernetes YAML with a verified Kubeconform release

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `target` | <p>Rendered YAML file or directory inside the caller workspace</p> | `true` | `""` |
| `kubernetes-version` | <p>Full Kubernetes version used for schema validation, such as 1.29.0</p> | `true` | `""` |
| `schema-path` | <p>Optional local schema file or directory inside the caller workspace</p> | `false` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/kubeconform-validate@<sha-completo>
  with:
    target:
    # Rendered YAML file or directory inside the caller workspace
    #
    # Required: true
    # Default: ""

    kubernetes-version:
    # Full Kubernetes version used for schema validation, such as 1.29.0
    #
    # Required: true
    # Default: ""

    schema-path:
    # Optional local schema file or directory inside the caller workspace
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/kubeconform-validate" version="<sha-completo>" -->

<!-- END_DOCS -->
