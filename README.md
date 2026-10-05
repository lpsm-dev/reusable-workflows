<!-- BEGIN_DOCS -->
<div align="center">

<a name="readme-top"></a>

Hello Human 👽! Bem-vindo ao meu repositório 👋

<img alt="gif-about" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/github.gif" width="225"/>

**Reusable workflows, composite actions e templates do GitHub Actions em um só lugar**

[![CI](https://github.com/lpsm-dev/reusable-workflows/actions/workflows/_ci.yaml/badge.svg)](https://github.com/lpsm-dev/reusable-workflows/actions/workflows/_ci.yaml)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](https://www.conventionalcommits.org/en/v1.0.0/)
[![Semantic Release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://semantic-release.gitbook.io/semantic-release)
[![Built with Devbox](https://jetpack.io/img/devbox/shield_galaxy.svg)](https://jetpack.io/devbox/docs/contributor-quickstart/)

</div>

<!-- START_TABLE_OF_CONTENTS -->

[1. Visão Geral](#1-visão-geral)<br>
&nbsp;&nbsp;&nbsp;[1.1. Objetivo](#11-objetivo)<br>
&nbsp;&nbsp;&nbsp;[1.2. Estrutura do repositório](#12-estrutura-do-repositório)<br>
&nbsp;&nbsp;&nbsp;[1.3. Workflow, action ou template?](#13-workflow-action-ou-template)<br>
[2. Catálogo](#2-catálogo)<br>
&nbsp;&nbsp;&nbsp;[2.1. Reusable workflows](#21-reusable-workflows)<br>
&nbsp;&nbsp;&nbsp;[2.2. Composite actions](#22-composite-actions)<br>
&nbsp;&nbsp;&nbsp;[2.3. Templates](#23-templates)<br>
[3. Implementação](#3-implementação)<br>
&nbsp;&nbsp;&nbsp;[3.1. Pré-requisitos](#31-pré-requisitos)<br>
&nbsp;&nbsp;&nbsp;[3.2. Chamando um reusable workflow](#32-chamando-um-reusable-workflow)<br>
&nbsp;&nbsp;&nbsp;[3.3. Usando uma composite action](#33-usando-uma-composite-action)<br>
&nbsp;&nbsp;&nbsp;[3.4. Copiando um template](#34-copiando-um-template)<br>
&nbsp;&nbsp;&nbsp;[3.5. Fixando a versão pelo SHA](#35-fixando-a-versão-pelo-sha)<br>
[4. Referências](#4-referências)<br>
[5. Contribuição](#5-contribuição)<br>
[6. Versionamento](#6-versionamento)<br>
[7. Troubleshooting](#7-troubleshooting)<br>
[8. Show your support](#8-show-your-support)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Visão Geral

## 1.1. Objetivo

Este repositório concentra as peças de GitHub Actions que se repetem entre os meus projetos. Em vez de copiar o mesmo YAML para cada repositório, o projeto chama a peça daqui, fixada em um commit, e só recebe mudanças quando decide atualizar esse commit.

## 1.2. Estrutura do repositório

```txt
.
├── .github/
│   ├── config/              # configuração das ferramentas deste repositório
│   ├── taskfiles/           # tasks incluídas pelo Taskfile.yaml
│   └── workflows/
│       ├── gitleaks.yaml    # reusable workflow público
│       └── _*.yaml          # CI e release deste repositório
├── actions/
│   └── <nome>/              # composite action: action.yaml + README.md
├── templates/
│   └── <ferramenta>/        # arquivos para copiar para o seu repositório
└── docs/
    ├── workflows/           # uma página por reusable workflow
    └── adrs/                # decisões de arquitetura
```

| Pasta | O que guarda | Quem usa | Como é consumido |
| --- | --- | --- | --- |
| `.github/workflows/` (sem `_`) | Reusable workflows: jobs inteiros, com `on: workflow_call` | Outros repositórios | `jobs.<id>.uses` |
| `.github/workflows/_*.yaml` | CI e release deste repositório | Só este repositório | Eventos como `push`, `pull_request` e disparo manual |
| `actions/<nome>/` | Composite actions: sequências de steps | Outros repositórios | `jobs.<id>.steps[*].uses` |
| `templates/<ferramenta>/` | Arquivos de configuração para começar um projeto | Quem configura um repositório novo | Cópia única, commitada no seu repositório |
| `.github/config/` | Configuração das ferramentas usadas aqui (Gitleaks, semantic-release, yamllint) | Só este repositório | Lida pelos workflows internos e pelo Taskfile |
| `docs/` | Página de cada reusable workflow e ADRs | Pessoas | Leitura |

Duas regras do GitHub explicam esse desenho:

- O GitHub só encontra um reusable workflow se o arquivo estiver direto em `.github/workflows/`. Subpastas não são suportadas. Por isso os workflows públicos e os internos dividem a mesma pasta, e o prefixo `_` marca os internos.
- Composite actions podem ficar em qualquer pasta. Aqui elas ficam em `actions/`, uma pasta por action, com o `README.md` ao lado do `action.yaml`. Como `.github/workflows/` não aceita subpastas, a documentação dos workflows fica em `docs/workflows/`.

As decisões completas estão nos ADRs, em [`docs/adrs/`](docs/adrs/).

## 1.3. Workflow, action ou template?

- **Reusable workflow**: reaproveita um ou mais jobs inteiros. Roda em runner próprio e é chamado no lugar de um job. Exemplo: o scan de segredos com Gitleaks.
- **Composite action**: reaproveita uma sequência de steps dentro de um job que já existe. Roda no runner e no workspace do job que a chama. Exemplo: publicar arquivos no S3 e invalidar o cache do CloudFront.
- **Template**: serve para quando a ferramenta precisa de um arquivo dentro do seu repositório, como a config do Gitleaks ou do semantic-release. Não existe `uses:` para isso: você copia o arquivo uma vez e passa a mantê-lo no seu projeto.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Catálogo

## 2.1. Reusable workflows

| Workflow | O que faz | Documentação |
| --- | --- | --- |
| [`gitleaks.yaml`](.github/workflows/gitleaks.yaml) | Procura segredos versionados com o Gitleaks, usando a config do repositório que chama | [docs/workflows/gitleaks.md](docs/workflows/gitleaks.md) |

## 2.2. Composite actions

| Action | O que faz | Documentação |
| --- | --- | --- |
| [`aws-cloudfront-deploy`](actions/aws-cloudfront-deploy/action.yaml) | Sincroniza uma pasta com um bucket S3 e invalida o cache da distribuição CloudFront | [README](actions/aws-cloudfront-deploy/README.md) |
| [`aws-ecr-create`](actions/aws-ecr-create/action.yaml) | Cria um repositório no Amazon ECR se ele ainda não existir | [README](actions/aws-ecr-create/README.md) |
| [`aws-eks-deploy`](actions/aws-eks-deploy/action.yaml) | Troca a imagem de um deployment no Amazon EKS com `kubectl set image` | [README](actions/aws-eks-deploy/README.md) |

Pré-requisitos de credenciais e observações de cada action estão no [catálogo de actions](actions/README.md).

## 2.3. Templates

| Template | Copiar para | Quando usar |
| --- | --- | --- |
| [`gitleaks/default.toml`](templates/gitleaks/default.toml) | `.github/config/.gitleaks.toml` | Ponto de partida para o workflow do Gitleaks, só com as regras padrão |
| [`gitleaks/azsk.toml`](templates/gitleaks/azsk.toml) | `.github/config/.gitleaks.toml` | Regras padrão mais as regras de credenciais do AzSK (Azure DevOps) |
| [`semantic-release/github.json`](templates/semantic-release/github.json) | `.releaserc.json` | Release com semantic-release publicando no GitHub |
| [`semantic-release/gitlab.json`](templates/semantic-release/gitlab.json) | `.releaserc.json` | Release com semantic-release publicando no GitLab, com pré-releases `rc` na branch `release` |

Detalhes de cada template em [`templates/README.md`](templates/README.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. Implementação

## 3.1. Pré-requisitos

- GitHub Actions habilitado no repositório que vai consumir as peças. Este repositório é público, então qualquer repositório pode chamá-lo, a menos que a política de Actions da organização bloqueie actions e workflows de fora.
- Para as actions de AWS, uma role IAM que confie no provedor OIDC do GitHub e `permissions: id-token: write` no job. Os detalhes estão no [catálogo de actions](actions/README.md#31-credenciais-aws).

## 3.2. Chamando um reusable workflow

O reusable workflow entra no lugar de um job inteiro:

```yaml
name: Gitleaks

on:
  pull_request:
  push:

permissions:
  contents: read

jobs:
  scan:
    uses: lpsm-dev/reusable-workflows/.github/workflows/gitleaks.yaml@<sha-completo>
    with:
      config: .github/config/.gitleaks.toml
```

## 3.3. Usando uma composite action

A composite action entra como um step dentro de um job seu:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      id-token: write
    steps:
    - uses: actions/checkout@<sha-completo>
    - uses: lpsm-dev/reusable-workflows/actions/aws-cloudfront-deploy@<sha-completo>
      with:
        aws-role-arn: arn:aws:iam::123456789012:role/github-deploy
        s3-bucket-name: meu-site
        s3-bucket-domain: s3.amazonaws.com
        path: dist
```

## 3.4. Copiando um template

Baixe o arquivo do commit que você escolheu e commite no seu repositório:

```bash
mkdir -p .github/config
curl -fsSL -o .github/config/.gitleaks.toml \
  https://raw.githubusercontent.com/lpsm-dev/reusable-workflows/<sha-completo>/templates/gitleaks/default.toml
```

A partir daí o arquivo é seu. Mudanças futuras no template não chegam sozinhas na sua cópia.

## 3.5. Fixando a versão pelo SHA

Tags e branches podem passar a apontar para outro commit, e aí o código que roda no seu pipeline muda junto, com o `GITHUB_TOKEN` do seu repositório. Um SHA completo, de 40 caracteres, sempre aponta para o mesmo commit. É a recomendação do GitHub em [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions).

Para descobrir o SHA mais recente da `main`:

```bash
git ls-remote https://github.com/lpsm-dev/reusable-workflows refs/heads/main
```

Para atualizar, troque o SHA num commit próprio, de preferência por pull request.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 4. Referências

Links relevantes para essa documentação:

- [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [Create a composite action](https://docs.github.com/en/actions/tutorials/create-actions/create-a-composite-action)
- [About custom actions](https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions)
- [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 5. Contribuição

Gostaria de contribuir? Isso é ótimo! Temos um guia de contribuição para te ajudar. Clique [aqui](CONTRIBUTING.md) para lê-lo. Ele também explica como adicionar um novo workflow, action ou template.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 6. Versionamento

Para verificar o histórico de mudanças, acesse o arquivo [**CHANGELOG.md**](CHANGELOG.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 7. Troubleshooting

Se você tiver algum problema, abra uma [issue](https://github.com/lpsm-dev/reusable-workflows/issues/new/choose) nesse projeto.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 8. Show your support

<div align="center">

Dê uma ⭐️ para este projeto se ele te ajudou!

<img alt="gif-footer" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/yoda.gif" width="225"/>

<br>
<br>

Feito com 💜 pelo **Time de DevOps** :wave: inspirado no [readme-md-generator](https://github.com/kefranabg/readme-md-generator)

</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
