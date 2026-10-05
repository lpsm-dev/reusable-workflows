<!-- BEGIN_DOCS -->
<div align="center">

<a name="readme-top"></a>

Hello Human 👽! Bem-vindo ao meu repositório 👋

<img alt="gif-about" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/github.gif" width="225"/>

**Reusable workflows e composite actions do GitHub Actions em um só lugar**

[![CI](https://github.com/lpsm-dev/reusable-workflows/actions/workflows/_ci.yaml/badge.svg)](https://github.com/lpsm-dev/reusable-workflows/actions/workflows/_ci.yaml)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](https://www.conventionalcommits.org/en/v1.0.0/)
[![Semantic Release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://semantic-release.gitbook.io/semantic-release)
[![Built with Devbox](https://jetpack.io/img/devbox/shield_galaxy.svg)](https://jetpack.io/devbox/docs/contributor-quickstart/)

</div>

<!-- START_TABLE_OF_CONTENTS -->

[1. Visão Geral](#1-visão-geral)<br>
&nbsp;&nbsp;&nbsp;[1.1. Objetivo](#11-objetivo)<br>
&nbsp;&nbsp;&nbsp;[1.2. Estrutura do repositório](#12-estrutura-do-repositório)<br>
&nbsp;&nbsp;&nbsp;[1.3. Workflow ou action?](#13-workflow-ou-action)<br>
[2. Segurança](#2-segurança)<br>
&nbsp;&nbsp;&nbsp;[2.1. Como cada risco é tratado](#21-como-cada-risco-é-tratado)<br>
&nbsp;&nbsp;&nbsp;[2.2. Pendências conhecidas](#22-pendências-conhecidas)<br>
&nbsp;&nbsp;&nbsp;[2.3. No seu pipeline](#23-no-seu-pipeline)<br>
[3. Catálogo](#3-catálogo)<br>
&nbsp;&nbsp;&nbsp;[3.1. Reusable workflows](#31-reusable-workflows)<br>
&nbsp;&nbsp;&nbsp;[3.2. Composite actions](#32-composite-actions)<br>
[4. Implementação](#4-implementação)<br>
&nbsp;&nbsp;&nbsp;[4.1. Pré-requisitos](#41-pré-requisitos)<br>
&nbsp;&nbsp;&nbsp;[4.2. Chamando um reusable workflow](#42-chamando-um-reusable-workflow)<br>
&nbsp;&nbsp;&nbsp;[4.3. Usando uma composite action](#43-usando-uma-composite-action)<br>
&nbsp;&nbsp;&nbsp;[4.4. Fixando a versão pelo SHA](#44-fixando-a-versão-pelo-sha)<br>
[5. Referências](#5-referências)<br>
[6. Contribuição](#6-contribuição)<br>
[7. Versionamento](#7-versionamento)<br>
[8. Troubleshooting](#8-troubleshooting)<br>
[9. Show your support](#9-show-your-support)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Visão Geral

## 1.1. Objetivo

Este repositório concentra as peças de GitHub Actions que se repetem entre os meus projetos. Em vez de copiar o mesmo YAML para cada repositório, o projeto chama a peça daqui, fixada em um commit, e só recebe mudanças quando decide atualizar esse commit.

Toda peça daqui segue o [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks). A seção [Segurança](#2-segurança) mostra como cada risco é tratado e o que ainda falta.

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
└── docs/
    ├── workflows/<nome>/    # página de cada reusable workflow e exemplos de config
    └── adrs/                # decisões de arquitetura
```

| Pasta | O que guarda | Quem usa | Como é consumido |
| --- | --- | --- | --- |
| `.github/workflows/` (sem `_`) | Reusable workflows: jobs inteiros, com `on: workflow_call` | Outros repositórios | `jobs.<id>.uses` |
| `.github/workflows/_*.yaml` | CI e release deste repositório | Só este repositório | Eventos como `push`, `pull_request` e disparo manual |
| `actions/<nome>/` | Composite actions: sequências de steps | Outros repositórios | `jobs.<id>.steps[*].uses` |
| `.github/config/` | Configuração das ferramentas usadas aqui (semantic-release e yamllint) | Só este repositório | Lida pelos workflows internos e pelo Taskfile |
| `docs/` | Página de cada reusable workflow, exemplos de config e ADRs | Pessoas | Leitura |

Duas regras do GitHub explicam esse desenho:

- O GitHub só encontra um reusable workflow se o arquivo estiver direto em `.github/workflows/`. Subpastas não são suportadas. Por isso os workflows públicos e os internos dividem a mesma pasta, e o prefixo `_` marca os internos.
- Composite actions podem ficar em qualquer pasta. Aqui elas ficam em `actions/`, uma pasta por action, com o `README.md` ao lado do `action.yaml`. Como `.github/workflows/` não aceita subpastas, a documentação de cada workflow fica em `docs/workflows/<nome>/`.

As decisões completas estão nos ADRs, em [`docs/adrs/`](docs/adrs/).

## 1.3. Workflow ou action?

- **Reusable workflow**: reaproveita um ou mais jobs inteiros. Roda em runner próprio e é chamado no lugar de um job. Exemplo: o scan de segredos com Gitleaks.
- **Composite action**: reaproveita uma sequência de steps dentro de um job que já existe. Roda no runner e no workspace do job que a chama. Exemplo: publicar arquivos no S3 e invalidar o cache do CloudFront.

E os arquivos de configuração? Cada projeto mantém os seus, como o `.github/config/.gitleaks.toml`. Os workflows daqui funcionam sem config quando a ferramenta tem um padrão razoável, então o projeto só commita um arquivo quando quer personalizar. Exemplos opcionais ficam na pasta de cada workflow, em `docs/workflows/<nome>/`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Segurança

Um workflow compartilhado roda no pipeline de todo repositório que o chama, com acesso a código, tokens e, às vezes, à nuvem. Uma falha aqui se espalha para todos eles. Por isso cada peça deste repositório parte do [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks), e os mesmos princípios valem para o pipeline de quem consome.

## 2.1. Como cada risco é tratado

| Risco | Como este repositório aplica |
| --- | --- |
| [CICD-SEC-1: Insufficient Flow Control Mechanisms](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-01-Insufficient-Flow-Control-Mechanisms) | Mudanças entram na `main` por pull request com squash. Quem chama fixa um SHA, então nada daqui chega a outro pipeline sem um pull request lá trocando o SHA. O release só roda na `main`, por disparo manual. |
| [CICD-SEC-2: Inadequate Identity and Access Management](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-02-Inadequate-Identity-And-Access-Management) | Os reusable workflows não recebem credenciais. O `aws-cloudfront-deploy` e o `aws-eks-deploy` assumem uma role via OIDC, com credencial temporária, em vez de usar chave de acesso fixa. |
| [CICD-SEC-3: Dependency Chain Abuse](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-03-Dependency-Chain-Abuse) | Actions de terceiros são fixadas pelo SHA completo, e quem chama fixa este repositório da mesma forma, como explica [Fixando a versão pelo SHA](#44-fixando-a-versão-pelo-sha). |
| [CICD-SEC-4: Poisoned Pipeline Execution](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-04-Poisoned-Pipeline-Execution) | Nenhum workflow usa `pull_request_target`, e os reusable workflows só respondem a `workflow_call`. Inputs entram nos scripts por `env:`, e não por `${{ }}` dentro do `run:`. |
| [CICD-SEC-5: Insufficient PBAC](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-05-Insufficient-PBAC) | Todo workflow declara `permissions`. Os reusable workflows públicos só leem o repositório, e escrita aparece só nos internos que precisam dela: o release e o lint. |
| [CICD-SEC-6: Insufficient Credential Hygiene](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-06-Insufficient-Credential-Hygiene) | O checkout usa `persist-credentials: false` quando o job não faz push, o Gitleaks mascara o segredo com `--redact`, e todo push e pull request deste repositório passa pelo scan de segredos. |
| [CICD-SEC-7: Insecure System Configuration](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-07-Insecure-System-Configuration) | Os jobs rodam em runners hospedados pelo GitHub, descartados ao fim de cada execução, com `timeout-minutes`. |
| [CICD-SEC-8: Ungoverned Usage of 3rd Party Services](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-08-Ungoverned-Usage-of-3rd-Party-Services) | Os workflows não mandam código nem token para serviços externos: o Gitleaks roda no runner e o resultado fica no log. Apps instalados no repositório, como o CodeRabbit, têm acesso por fora do pipeline e precisam ser revisados nas configurações do repositório, em GitHub Apps. |
| [CICD-SEC-9: Improper Artifact Integrity Validation](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-09-Improper-Artifact-Integrity-Validation) | O binário do Gitleaks só é instalado se o SHA256 bater com o valor fixado no workflow. |
| [CICD-SEC-10: Insufficient Logging and Visibility](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-10-Insufficient-Logging-And-Visibility) | Uma falha aparece no log do job e derruba a execução. O step `Scan` do Gitleaks registra qual config usou. |

## 2.2. Pendências conhecidas

O que ainda não segue a tabela acima:

- A `main` não tem proteção de branch nem ruleset. A revisão por pull request é prática, não regra (CICD-SEC-1).
- O token padrão do repositório tem permissão de escrita, qualquer action pode rodar, e a exigência de SHA nas actions (`sha_pinning_required`) está desligada. Os workflows daqui declaram `permissions`, mas o padrão deveria ser só leitura (CICD-SEC-3, CICD-SEC-5 e CICD-SEC-7).
- O `_check-workflows.yaml`, o `_release.yaml`, o `aws-cloudfront-deploy` e o `aws-eks-deploy` referenciam actions por tag (`@v4`, `@v1`), e não por SHA (CICD-SEC-3).
- As composite actions de AWS interpolam `${{ inputs.* }}` dentro do `run:` (CICD-SEC-4).
- No `_check-workflows.yaml`, o actionlint roda com `continue-on-error: true` e nunca falha o build, e o checkout não usa `persist-credentials: false` (CICD-SEC-6 e CICD-SEC-10).
- O `_release.yaml` pede `id-token: write` sem usar, não tem `timeout-minutes` e instala pacotes npm que não usa (`@semantic-release/gitlab`, `@semantic-release/npm`, `@semantic-release/exec` e o commitlint), fixados por versão mas sem lockfile (CICD-SEC-3, CICD-SEC-5 e CICD-SEC-7).

## 2.3. No seu pipeline

Os mesmos princípios valem para o repositório que chama:

- Fixe este repositório e qualquer action de terceiros pelo SHA completo.
- Declare `permissions` mínimas no workflow que chama. O GitHub deixa um reusable workflow reduzir as permissões que recebe, mas nunca aumentar, então o limite é o que você concede.
- Proteja a branch principal e exija revisão em pull request.
- Deixe o token padrão do repositório como só leitura, em Settings > Actions > General.
- Para acessar a nuvem, prefira OIDC a segredos de longa duração.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. Catálogo

## 3.1. Reusable workflows

| Workflow | O que faz | Documentação |
| --- | --- | --- |
| [`gitleaks.yaml`](.github/workflows/gitleaks.yaml) | Procura segredos versionados com o Gitleaks. A config é opcional: sem ela, usa as regras padrão | [README](docs/workflows/gitleaks/README.md) |

## 3.2. Composite actions

| Action | O que faz | Documentação |
| --- | --- | --- |
| [`aws-cloudfront-deploy`](actions/aws-cloudfront-deploy/action.yaml) | Sincroniza uma pasta com um bucket S3 e invalida o cache da distribuição CloudFront | [README](actions/aws-cloudfront-deploy/README.md) |
| [`aws-ecr-create`](actions/aws-ecr-create/action.yaml) | Cria um repositório no Amazon ECR se ele ainda não existir | [README](actions/aws-ecr-create/README.md) |
| [`aws-eks-deploy`](actions/aws-eks-deploy/action.yaml) | Troca a imagem de um deployment no Amazon EKS com `kubectl set image` | [README](actions/aws-eks-deploy/README.md) |

Pré-requisitos de credenciais e observações de cada action estão no [catálogo de actions](actions/README.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 4. Implementação

## 4.1. Pré-requisitos

- GitHub Actions habilitado no repositório que vai consumir as peças. Este repositório é público, então qualquer repositório pode chamá-lo, a menos que a política de Actions da organização bloqueie actions e workflows de fora.
- Para as actions de AWS, uma role IAM que confie no provedor OIDC do GitHub e `permissions: id-token: write` no job. Os detalhes estão no [catálogo de actions](actions/README.md#31-credenciais-aws).

## 4.2. Chamando um reusable workflow

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
```

Para usar uma config própria, passe `with: config: <caminho>`. A ordem de busca está na [página do workflow](docs/workflows/gitleaks/README.md#23-qual-config-é-usada).

## 4.3. Usando uma composite action

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

## 4.4. Fixando a versão pelo SHA

Tags e branches podem passar a apontar para outro commit, e aí o código que roda no seu pipeline muda junto, com o `GITHUB_TOKEN` do seu repositório. Um SHA completo, de 40 caracteres, sempre aponta para o mesmo commit. É a recomendação do GitHub em [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use#using-third-party-actions).

Para descobrir o SHA mais recente da `main`:

```bash
git ls-remote https://github.com/lpsm-dev/reusable-workflows refs/heads/main
```

Para atualizar, troque o SHA num commit próprio, de preferência por pull request.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 5. Referências

Links relevantes para essa documentação:

- [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [Create a composite action](https://docs.github.com/en/actions/tutorials/create-actions/create-a-composite-action)
- [About custom actions](https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions)
- [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 6. Contribuição

Gostaria de contribuir? Isso é ótimo! Temos um guia de contribuição para te ajudar. Clique [aqui](CONTRIBUTING.md) para lê-lo. Ele também explica como adicionar um novo workflow ou action.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 7. Versionamento

Para verificar o histórico de mudanças, acesse o arquivo [**CHANGELOG.md**](CHANGELOG.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 8. Troubleshooting

Se você tiver algum problema, abra uma [issue](https://github.com/lpsm-dev/reusable-workflows/issues/new/choose) nesse projeto.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 9. Show your support

<div align="center">

Dê uma ⭐️ para este projeto se ele te ajudou!

<img alt="gif-footer" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/yoda.gif" width="225"/>

<br>
<br>

Feito com 💜 pelo **Time de DevOps** :wave: inspirado no [readme-md-generator](https://github.com/kefranabg/readme-md-generator)

</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
