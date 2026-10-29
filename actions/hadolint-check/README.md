<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

Após o checkout, valide os Dockerfiles rastreados pelo Git:

```yaml
- uses: lpsm-dev/reusable-workflows/actions/hadolint-check@56f5dbe1a8091b2c2dea19516375689aa9d0f017
  with:
    target: .
```

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/hadolint-check" version="<sha-completo>" -->
# Hadolint Check

## Description

Check Git-tracked Dockerfiles with a verified Hadolint release

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `target` | <p>Dockerfile or directory inside the caller workspace to check</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/hadolint-check@<sha-completo>
  with:
    target:
    # Dockerfile or directory inside the caller workspace to check
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/hadolint-check" version="<sha-completo>" -->

<!-- END_DOCS -->
