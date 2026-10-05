<!-- BEGIN_DOCS -->

[◀ Voltar](../../README.md)

<div align="center">

<a name="readme-top"></a>

**Reusable workflow do Gitleaks**

</div>

<!-- START_TABLE_OF_CONTENTS -->

[1. Visão Geral](#1-visão-geral)<br>
[2. Uso](#2-uso)<br>
&nbsp;&nbsp;&nbsp;[2.1. Pré-requisitos](#21-pré-requisitos)<br>
&nbsp;&nbsp;&nbsp;[2.2. Exemplo](#22-exemplo)<br>
&nbsp;&nbsp;&nbsp;[2.3. Entradas](#23-entradas)<br>
[3. Como funciona](#3-como-funciona)<br>
[4. Segurança](#4-segurança)<br>
[5. Manutenção](#5-manutenção)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Visão Geral

O [`gitleaks.yaml`](../../.github/workflows/gitleaks.yaml) procura segredos versionados, como tokens, chaves privadas e senhas, no código do repositório que o chama. O único gatilho é `workflow_call`: ele não roda sozinho, só quando outro workflow o chama.

A config do Gitleaks fica no repositório que chama, e não aqui. Cada projeto escolhe as próprias regras.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Uso

## 2.1. Pré-requisitos

O repositório precisa ter uma config do Gitleaks. O caminho padrão é `.github/config/.gitleaks.toml`. Para começar, copie um dos templates de [`templates/gitleaks/`](../../templates/gitleaks/):

```bash
mkdir -p .github/config
curl -fsSL -o .github/config/.gitleaks.toml \
  https://raw.githubusercontent.com/lpsm-dev/reusable-workflows/<sha-completo>/templates/gitleaks/default.toml
```

## 2.2. Exemplo

Crie um workflow no seu repositório, por exemplo `.github/workflows/gitleaks.yaml`:

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

Troque `<sha-completo>` pelo SHA de 40 caracteres de um commit deste repositório. O motivo está em [Fixando a versão pelo SHA](../../README.md#35-fixando-a-versão-pelo-sha).

## 2.3. Entradas

| Nome | Tipo | Obrigatório | Padrão | Descrição |
| --- | --- | --- | --- | --- |
| `config` | `string` | Não | `.github/config/.gitleaks.toml` | Caminho da config do Gitleaks, relativo à raiz do repositório que chama |

O workflow não recebe `secrets` e não tem `outputs`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. Como funciona

O job `scan` tem timeout de 10 minutos e faz três passos:

1. Faz checkout do repositório que chama com `persist-credentials: false`, para o token não ficar gravado no `.git/config` do runner.
2. Baixa o Gitleaks 8.23.3 da release oficial e confere o SHA256 do arquivo antes de instalar. Se o checksum não bater, o job para ali.
3. Extrai o `HEAD` com `git archive` para uma pasta temporária e roda `gitleaks detect --no-git --redact` nela, com a config informada.

O scan cobre os arquivos do commit atual, não o histórico. Um segredo que foi commitado e depois removido não aparece.

Se o Gitleaks encontrar algo, o job falha e o achado aparece no log, com o valor mascarado pelo `--redact`. Não há upload de relatório nem comentário no pull request.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 4. Segurança

O desenho segue o [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks):

- O token tem só `contents: read`.
- O gatilho é só `workflow_call`. Não existe `pull_request_target`, então código de fork não roda com as permissões do repositório base.
- Nenhum secret é declarado e nenhuma credencial de deploy passa pelo workflow.
- O `actions/checkout` está fixado por SHA, e o binário do Gitleaks é validado por SHA256.
- `concurrency` cancela a execução anterior do mesmo ref.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 5. Manutenção

Para atualizar o Gitleaks, altere `version` e `checksum` no step `Install Gitleaks`. O checksum de cada arquivo está no `gitleaks_<versão>_checksums.txt` publicado na [release](https://github.com/gitleaks/gitleaks/releases).

Antes de abrir o pull request, rode o scan local com a nova versão usando cada template de [`templates/gitleaks/`](../../templates/gitleaks/). Versões novas do Gitleaks já invalidaram configs antigas: o `azsk.toml` usava a chave `regex` da versão 7 e não carregava na 8.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
