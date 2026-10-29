<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

Esta action procura vulnerabilidades em uma pasta ou em uma imagem fixada por digest. Achados `HIGH` ou `CRITICAL` fazem o job falhar. O workflow que chama faz o checkout para `fs` e autentica no registry privado para `image`. O Trivy baixa a base de vulnerabilidades durante a execução, e uma falha nessa atualização bloqueia o scan. Caminhos de arquivo são relativos a `GITHUB_WORKSPACE`. O runner suportado é Ubuntu 24.04 x64.

Após o checkout, analise os arquivos do repositório:

```yaml
- uses: lpsm-dev/reusable-workflows/actions/trivy-scan@274e31d0995a09c08e9362b6aa7e7dd4d28fbd6e
  with:
    scan-type: fs
    target: .
```

<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/trivy-scan" version="<sha-completo>" -->
# Trivy scan

## Description

Scan a filesystem path or digest-pinned image for high and critical vulnerabilities

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `scan-type` | <p>Scan target type, fs or image</p> | `true` | `""` |
| `target` | <p>Workspace-relative path for fs or digest-pinned image reference for image</p> | `true` | `""` |
| `ignorefile` | <p>Optional workspace-relative Trivy ignore file</p> | `false` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: lpsm-dev/reusable-workflows/actions/trivy-scan@<sha-completo>
  with:
    scan-type:
    # Scan target type, fs or image
    #
    # Required: true
    # Default: ""

    target:
    # Workspace-relative path for fs or digest-pinned image reference for image
    #
    # Required: true
    # Default: ""

    ignorefile:
    # Optional workspace-relative Trivy ignore file
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-all source="action.yaml" project="lpsm-dev/reusable-workflows/actions/trivy-scan" version="<sha-completo>" -->

<!-- END_DOCS -->
