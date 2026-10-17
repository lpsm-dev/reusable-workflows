---
status: accepted
date: 2026-10-05
---

# Release sem commit na main e ruleset na main

## 1. Contexto

### 1.1. Situação atual

O `_release.yaml` rodava o semantic-release com `@semantic-release/changelog` e `@semantic-release/git`. Esses plugins fazem commit do `CHANGELOG.md` e do `README.md` direto na `main` com o `GITHUB_TOKEN`. A `main` não tinha proteção nem ruleset, então qualquer push chegava nela sem pull request nem CI.

### 1.2. Problema

Proteger a `main` com um ruleset sem quebrar o release.

### 1.3. Drivers

- **CICD-SEC-1 (Insufficient Flow Control):** toda mudança na `main` deve passar por pull request com CI verde.
- **CICD-SEC-4 (Poisoned Pipeline Execution):** nenhum workflow deve conseguir empurrar código na `main`.

### 1.4. Constraints

- Um ruleset que exige pull request bloqueia o commit que o release fazia.
- Um único mantenedor não consegue aprovar o próprio pull request.

## 2. Decisão

Decidimos que o release cria só a tag e o GitHub Release, e que a `main` ganha um ruleset sem exceção, aceitando perder o `CHANGELOG.md` atualizado.

- O release cria a tag e o GitHub Release com as notas da versão. Saem `@semantic-release/changelog` e `@semantic-release/git`. O `CHANGELOG.md` fica como histórico até a versão 1.0.0.
- A `main` ganha um ruleset sem exceção:
  - pull request obrigatório com merge por squash;
  - os checks `scan / scan`, `Action Lint` e `YAML Lint`, emitidos pelo GitHub Actions, verdes e com a branch atualizada;
  - force push e exclusão bloqueados.
- O ruleset não exige aprovação, porque ninguém aprova o próprio pull request.
- O token padrão do repositório passa a ser só leitura. Cada workflow declara as permissões de que precisa.

## 3. Opções consideradas

### 3.1. Opção A: release sem commit e ruleset completo

| Prós | Contras |
|---|---|
| A `main` só muda por pull request com CI verde | O `CHANGELOG.md` deixa de ser atualizado |
| Nenhuma credencial nova | |

**Adotada**, porque fecha o CICD-SEC-1 sem exceção no ruleset.

### 3.2. Opção B: bypass do bot do Actions no ruleset

| Prós | Contras |
|---|---|
| O release continua igual | Qualquer workflow com escrita passa a poder alterar a `main` |

**Rejeitada**, porque reabre o CICD-SEC-4.

### 3.3. Opção C: ruleset parcial, só contra force push e exclusão

| Prós | Contras |
|---|---|
| O release continua igual | Push direto na `main` continua possível |

**Rejeitada**, porque não fecha o CICD-SEC-1.

### 3.4. Opção D: GitHub App próprio com bypass para manter o commit do changelog

| Prós | Contras |
|---|---|
| Mantém o `CHANGELOG.md` | Exige chave privada de longa duração e mais infraestrutura |

**Rejeitada**, porque o GitHub Release já cobre o que o arquivo guardava.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Sem aprovação obrigatória | Um pull request entra só com CI verde | Exigir um aprovador quando houver mais de um mantenedor |
| `CHANGELOG.md` congelado | O histórico novo fica fora do repositório | As notas ficam nos GitHub Releases |

## 5. Consequências

### 5.1. Positivas

- As notas de versão passam a ficar nos GitHub Releases.
- Com todas as actions fixadas por SHA, a opção `sha_pinning_required` pode ser ligada nas configurações do repositório.

### 5.2. Negativas

- Todo workflow que precisar alterar a `main` tem que abrir um pull request.

## 6. Referências

- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks).
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).
- [adr-005-adopt-community-practices.md](adr-005-adopt-community-practices.md): soma o check `Zizmor` e o formato de tag `vX.Y.Z`.
