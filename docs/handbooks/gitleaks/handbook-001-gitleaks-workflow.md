---
date: 2026-10-05
---

# Reusable workflow do Gitleaks

## 1. O que é

O [`gitleaks.yaml`](../../../.github/workflows/gitleaks.yaml) procura segredos versionados no código do repositório que o chama, como tokens, chaves privadas e senhas. O único gatilho é `workflow_call`: ele não roda sozinho, só quando outro workflow o chama.

A config é opcional. Sem ela, o Gitleaks usa as regras padrão dele. Quando o projeto quer regras próprias ou uma allowlist, ele commita um arquivo de config no próprio repositório.

## 2. Como as peças se ligam

### 2.1. Exemplo de uso

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
    uses: lpsm-dev/reusable-workflows/.github/workflows/gitleaks.yaml@<sha-completo>  # vX.Y.Z
```

Troque `<sha-completo>` pelo SHA de 40 caracteres de uma versão deste repositório. O motivo está em [Fixando a versão pelo SHA](../../../README.md#44-fixando-a-versão-pelo-sha).

### 2.2. Entradas

| Nome | Tipo | Obrigatório | Padrão | Descrição |
| --- | --- | --- | --- | --- |
| `config` | `string` | Não | vazio | Caminho da config do Gitleaks, relativo à raiz do repositório que chama |

O workflow não recebe `secrets` e não tem `outputs`.

### 2.3. Qual config é usada

1. Se `config` for informado, o workflow usa esse arquivo. Se ele não existir, o job falha.
2. Sem `config`, o workflow usa `.github/config/.gitleaks.toml`, se o arquivo existir.
3. Sem nenhum dos dois, o próprio Gitleaks procura um `.gitleaks.toml` na raiz do repositório. Se não achar, usa as regras padrão.

O log do step `Scan` mostra qual caminho foi seguido.

### 2.4. Exemplos de config

#### 2.4.1. Allowlist

Para ignorar arquivos que geram falso positivo sem perder as regras padrão, crie `.github/config/.gitleaks.toml` no seu repositório:

```toml
[extend]
useDefault = true

[allowlist]
description = "Exemplos públicos que não são segredos"
paths = [
  '''docs/exemplos/.*''',
]
```

#### 2.4.2. AzSK

A config deste repositório, [`.github/config/.gitleaks.toml`](../../../.github/config/.gitleaks.toml), traz as regras padrão mais 39 regras de credenciais do AzSK (Azure DevOps), com allowlists para reduzir falso positivo. Para usar no seu repositório, copie o arquivo para o mesmo caminho:

```bash
SHA="$(git ls-remote https://github.com/lpsm-dev/reusable-workflows refs/heads/main | cut -f1)"
mkdir -p .github/config
curl -fsSL -o .github/config/.gitleaks.toml \
  "https://raw.githubusercontent.com/lpsm-dev/reusable-workflows/${SHA}/.github/config/.gitleaks.toml"
```

O primeiro comando pega o SHA atual da `main`. Para usar outro commit, atribua o SHA completo dele a `SHA`.

O CI deste repositório escaneia o próprio código com esse arquivo, achado pela busca padrão. Se uma versão nova do Gitleaks deixar de carregá-lo, o CI falha.

### 2.5. Como funciona

O job `scan` tem timeout de 10 minutos e faz três passos:

1. Faz checkout do repositório que chama com `persist-credentials: false`, para o token não ficar gravado no `.git/config` do runner.
2. Baixa o Gitleaks 8.23.3 da release oficial e confere o SHA256 do arquivo antes de instalar. Se o checksum não bater, o job para ali.
3. Extrai o `HEAD` com `git archive` para uma pasta temporária e roda `gitleaks detect --no-git --redact` nela, com a config escolhida conforme [Qual config é usada](#23-qual-config-é-usada).

O scan cobre os arquivos do commit atual, não o histórico. Um segredo que foi commitado e depois removido não aparece.

Se o Gitleaks encontrar algo, o job falha e o achado aparece no log, com o valor mascarado pelo `--redact`. Não há upload de relatório nem comentário no pull request.

### 2.6. Segurança

O desenho segue o [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks). A visão geral do repositório está na seção [Segurança](../../../README.md#2-segurança) do README.

- **CICD-SEC-2 e CICD-SEC-6:** nenhum secret é declarado, nenhuma credencial de deploy passa pelo workflow, o checkout usa `persist-credentials: false` e o scan roda com `--redact`.
- **CICD-SEC-3 e CICD-SEC-9:** o `actions/checkout` está fixado por SHA, e o binário do Gitleaks só é instalado se o SHA256 bater.
- **CICD-SEC-4:** o gatilho é só `workflow_call`, sem `pull_request_target`, e o input `config` chega ao script por `env:`.
- **CICD-SEC-5:** o workflow declara `permissions: {}`, e o job pede só `contents: read`.
- **CICD-SEC-7:** o job roda em runner hospedado pelo GitHub, com timeout de 10 minutos, e `concurrency` cancela a execução anterior do mesmo ref.
- **CICD-SEC-8:** nada sai do runner: não há upload de relatório nem integração externa.
- **CICD-SEC-10:** a falha derruba o job e aparece no log, junto com a config que foi usada.

### 2.7. Manutenção

Para atualizar o Gitleaks, altere `version` e `checksum` no step `Install Gitleaks`. O checksum de cada arquivo está no `gitleaks_<versão>_checksums.txt` publicado na [release](https://github.com/gitleaks/gitleaks/releases).

O CI valida a config do AzSK em todo pull request, então uma versão que invalide configs antigas aparece ali. Sem essa validação, o arquivo ficou de dezembro de 2024 a outubro de 2026 sem carregar no Gitleaks 8, porque usava a chave `regex` da versão 7.

## 3. Para onde seguir

- Decisões sobre o layout, a config opcional e o local desta página: [adr-001](../../adrs/adr-001-layout.md), [adr-004](../../adrs/adr-004-remove-templates.md) e [adr-006](../../adrs/adr-006-docs-taxonomy.md).
- Catálogo dos reusable workflows e das composite actions: [README](../../../README.md#3-catálogo).
- Como adicionar um workflow novo: [CONTRIBUTING](../../../CONTRIBUTING.md#31-reusable-workflow).
