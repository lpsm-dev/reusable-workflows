<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<div align="center">

<a name="readme-top"></a>

**Templates**

</div>

<!-- START_TABLE_OF_CONTENTS -->

[1. Visão Geral](#1-visão-geral)<br>
[2. Gitleaks](#2-gitleaks)<br>
[3. semantic-release](#3-semantic-release)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Visão Geral

Algumas ferramentas precisam de um arquivo de configuração dentro do repositório do projeto, e o GitHub Actions não tem `uses:` para isso. Esta pasta guarda esses arquivos prontos para copiar.

A regra é: copie uma vez, commite no seu repositório e mantenha a cópia por lá. Nenhum workflow executa nada desta pasta, e mudanças aqui não chegam sozinhas nas cópias que já existem.

Cada ferramenta tem a sua subpasta, e o nome do arquivo indica a variante: `templates/<ferramenta>/<variante>.<extensão>`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Gitleaks

Config para o reusable workflow do Gitleaks, documentado em [`docs/workflows/gitleaks.md`](../docs/workflows/gitleaks.md). Copie para `.github/config/.gitleaks.toml`, que é o caminho padrão do input `config`.

| Arquivo | Conteúdo |
| --- | --- |
| [`gitleaks/default.toml`](gitleaks/default.toml) | Só as regras padrão do Gitleaks (`[extend] useDefault = true`). Comece por aqui. |
| [`gitleaks/azsk.toml`](gitleaks/azsk.toml) | Regras padrão mais 39 regras de credenciais do AzSK (Azure DevOps), com allowlists para reduzir falso positivo. |

```bash
mkdir -p .github/config
curl -fsSL -o .github/config/.gitleaks.toml \
  https://raw.githubusercontent.com/lpsm-dev/reusable-workflows/<sha-completo>/templates/gitleaks/default.toml
```

Os dois arquivos carregam no Gitleaks 8.23.3, a versão que o workflow instala.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. semantic-release

Config do [semantic-release](https://semantic-release.gitbook.io/semantic-release) para gerar versão, changelog e release a partir de commits no padrão [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Copie para `.releaserc.json` na raiz do repositório.

| Arquivo | Publica em | Branches |
| --- | --- | --- |
| [`semantic-release/github.json`](semantic-release/github.json) | GitHub Releases (`@semantic-release/github`) | `main` |
| [`semantic-release/gitlab.json`](semantic-release/gitlab.json) | GitLab Releases (`@semantic-release/gitlab`) | `main` e `release`, com pré-releases `rc` |

Os dois atualizam o `CHANGELOG.md` e fazem commit dele com `@semantic-release/git`. O `github.json` parte da config que este repositório usa no próprio release, em [`.github/config/.releaserc.json`](../.github/config/.releaserc.json).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
