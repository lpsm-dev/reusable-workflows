<!-- BEGIN_DOCS -->
<a name="readme-top"></a>

<div align="center">

<img alt="gif-about" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/github.gif" width="225"/>

**Reusable Workflows**

[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](https://www.conventionalcommits.org/en/v1.0.0/)
[![Semantic Release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://semantic-release.gitbook.io/semantic-release)
[![Built with Devbox](https://jetpack.io/img/devbox/shield_galaxy.svg)](https://jetpack.io/devbox/docs/contributor-quickstart/)

Centralized custom actions and reusable-workflows in GitHub

</div>

# Sumário

- [Sumário](#sumário)
- [Gitleaks](#gitleaks)
- [Referências](#referências)
- [Contribuição](#contribuição)
- [Versionamento](#versionamento)
- [Troubleshooting](#troubleshooting)
- [Show your support](#show-your-support)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Gitleaks

`.github/workflows/gitleaks.yaml` responde só a `workflow_call`. A config fica no repositório que chama. O input `config` é o caminho do TOML, relativo à raiz desse repositório. O padrão é `.github/config/.gitleaks.toml`.

As pastas em `actions/` são composite actions (`action.yaml`). O Gitleaks daqui é um reusable workflow.

## Como chamar

No workflow do projeto, pina o commit completo deste repositório:

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

O CI deste repositório chama o mesmo arquivo por caminho relativo, sem `@ref`:

```yaml
jobs:
  scan:
    uses: ./.github/workflows/gitleaks.yaml
```

## Por que pinar o SHA completo

Tag e branch mudam de commit. O código executado no caller muda junto, com o `GITHUB_TOKEN` daquele repositório. Um SHA de 40 caracteres identifica um commit e permanece nesse commit. Versão nova: o projeto troca o SHA num commit próprio.

## O que fica de fora

Release continua no repositório de cada projeto. Este workflow não declara `secrets` e não recebe credencial de deploy. Também não usa `pull_request_target`.

O job faz checkout com `persist-credentials: false`, instala o Gitleaks 8.23.3, confere o SHA256 `73a35edc2285afd689e712b8e0ebad3f2eaf94b0d67cd6e1f0ec693ac751bb4a` e escaneia `git archive HEAD` com `--redact`. A falha aparece no log. Não há upload de relatório.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Referências

Links relevantes para essa documentação:

- [GitHub Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [GitHub Custom Actions](https://docs.github.com/en/actions/creating-actions/about-custom-actions)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Contribuição

Gostaria de contribuir? Isso é ótimo! Temos um guia de contribuição para te ajudar. Clique [aqui](CONTRIBUTING.md) para lê-lo.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Versionamento

Para verificar o histórico de mudanças, acesse o arquivo [**CHANGELOG.md**](CHANGELOG.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Troubleshooting

Se você tiver algum problema, abra uma [issue](https://github.com/lpsm-dev/resume/issues/new/choose) nesse projeto.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Show your support

<div align="center">

Dê uma ⭐️ para este projeto se ele te ajudou!

<img alt="gif-footer" src="https://github.com/lpsm-dev/lpsm-dev/blob/0062b174ec9877e6dfc78817f314b4a0690f63ff/.github/assets/yoda.gif" width="225"/>

<br>
<br>

Feito com 💜 pelo **Time de DevOps** :wave: inspirado no [readme-md-generator](https://github.com/kefranabg/readme-md-generator)

</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
