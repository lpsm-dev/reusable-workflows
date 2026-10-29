<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/shellcheck-check" version="<sha-completo>" -->
# ShellCheck Check

## Description

Check Git-tracked Shell scripts with a verified ShellCheck release

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `target` | <p>File or directory inside the caller workspace to check</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/shellcheck-check@<sha-completo>
  with:
    target:
    # File or directory inside the caller workspace to check
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/shellcheck-check" version="<sha-completo>" -->

<!-- END_DOCS -->
