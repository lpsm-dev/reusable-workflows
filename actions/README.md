<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<div align="center">

<a name="readme-top"></a>

**Composite actions**

</div>

<!-- START_TABLE_OF_CONTENTS -->

[1. Visão Geral](#1-visão-geral)<br>
[2. Catálogo](#2-catálogo)<br>
[3. Uso](#3-uso)<br>
&nbsp;&nbsp;&nbsp;[3.1. Credenciais AWS](#31-credenciais-aws)<br>
&nbsp;&nbsp;&nbsp;[3.2. Observações](#32-observações)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Visão Geral

Uma composite action agrupa steps que se repetem em vários jobs. Ela roda dentro do job que a chama, no mesmo runner e com o mesmo workspace, como se os steps estivessem escritos ali.

O GitHub também aceita actions em JavaScript e em container Docker. Este repositório usa só composite, porque os steps são comandos de shell e de CLI e não precisam de build nem de imagem.

Cada action tem uma pasta com o `action.yaml` e um `README.md`. O README é gerado a partir do `action.yaml` pelo `task github:action:docs`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Catálogo

| Action | O que faz |
| --- | --- |
| [`aws-cloudfront-deploy`](aws-cloudfront-deploy/README.md) | Sincroniza uma pasta com um bucket S3 e invalida o cache da distribuição CloudFront que usa esse bucket como origem |
| [`aws-ecr-create`](aws-ecr-create/README.md) | Cria um repositório no Amazon ECR se ele ainda não existir |
| [`aws-eks-deploy`](aws-eks-deploy/README.md) | Troca a imagem de um deployment no Amazon EKS com `kubectl set image`, usando uma imagem do ECR |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. Uso

Referencie a pasta da action e fixe o SHA completo de um commit deste repositório:

```yaml
steps:
- uses: lpsm-dev/reusable-workflows/actions/aws-ecr-create@<sha-completo>
  with:
    repository-name: minha-app
```

## 3.1. Credenciais AWS

- `aws-cloudfront-deploy` e `aws-eks-deploy` assumem a role informada em `aws-role-arn` com o `aws-actions/configure-aws-credentials`, via OIDC. O job precisa de `permissions: id-token: write`, e a role precisa confiar no provedor OIDC do GitHub. O passo a passo está em [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws).
- `aws-ecr-create` não configura credenciais. Rode o `aws-actions/configure-aws-credentials` antes dela, no mesmo job.

## 3.2. Observações

- O `aws-eks-deploy` monta a imagem como `<registry do ECR>/<image-name>:<image-tag>` e atualiza o container que tem o mesmo nome do deployment (`app-name`). Se o container tiver outro nome, o `kubectl set image` falha.
- O `aws-cloudfront-deploy` escolhe a primeira distribuição cuja primeira origem contém `<s3-bucket-name>.<s3-bucket-domain>` e invalida `/*` nela. O step espera a invalidação terminar.
- As actions de terceiros usadas aqui são fixadas por SHA, e os inputs chegam aos scripts por `env:`, como pede o [checklist de segurança](../CONTRIBUTING.md#4-segurança).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
