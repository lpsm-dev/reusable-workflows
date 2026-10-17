---
status: accepted
date: 2026-10-17
---

# Práticas oficiais e da comunidade adotadas depois da pesquisa

## 1. Contexto

### 1.1. Situação atual

A [research-001](../research/research-001-github-reusable-pipelines-organization.md) comparou este repositório com a documentação do GitHub e com 20 repositórios públicos. A seção de comparação da pesquisa lista onde este repositório diverge:

- Os pins por SHA não tinham atualização automática. Os 20 repositórios usam Dependabot ou Renovate.
- O `_release.yaml` instalava o semantic-release sem lockfile, com o Node em `lts/*`.
- O nível superior dos workflows dava `contents: read` a todo job. O GitHub Well-Architected recomenda `permissions: {}` no topo e permissões por job.
- Nenhum lint verificava as composite actions. O zizmor audita workflows e actions.
- Não havia CODEOWNERS nem SECURITY.md.
- As tags não tinham o prefixo `v`, que 12 de 16 repositórios com tags usam por padrão.
- O devbox declarava versões de gitleaks e actionlint diferentes das que o CI instala.

### 1.2. Problema

Escolher quais divergências corrigir, sem mudar o layout do [adr-001](adr-001-layout.md) nem o fluxo de release do [adr-003](adr-003-release-without-commits.md).

### 1.3. Drivers

- **Cadeia de dependência (CICD-SEC-3):** pins atualizados e dependências transitivas fixas.
- **Menor privilégio (CICD-SEC-5):** cada job pede só o que usa.
- **Convergência:** o que quase todos os 20 repositórios fazem tem custo baixo de adoção.

### 1.4. Constraints

- O consumo continua por SHA, num repositório só.
- O release continua sem commit na `main`.

## 2. Decisão

Decidimos adotar as práticas abaixo, aceitando um job de CI a mais, um lockfile para manter e uma troca de formato de tag.

- **Dependabot.** `.github/dependabot.yml` cobre o ecossistema `github-actions` em `/` e `/actions/*` e o ecossistema `npm` em `.github/config/release`. Roda toda semana, com um pull request agrupado por ecossistema e cooldown de 7 dias antes de propor uma versão nova, como pede o zizmor.
- **Release com lockfile.** O semantic-release e os plugins ficam em `.github/config/release/`, com `package.json`, `package-lock.json` e `.releaserc.json`. O job roda `npm ci` nessa pasta e executa o binário a partir dela, porque o semantic-release resolve os plugins pelo diretório de trabalho. O Node fica fixo na LTS 24.22.0.
- **Permissões.** Todo workflow declara `permissions: {}` no topo, e cada job declara o que usa.
- **zizmor.** O job `Zizmor` de `_check-workflows.yaml` audita `.github/workflows/` e `actions/` em modo offline. O binário tem versão e SHA256 fixados, como o actionlint. O check entra no ruleset da `main`.
- **CODEOWNERS e SECURITY.md.** O CODEOWNERS dá todos os caminhos ao dono do repositório. O ruleset continua sem exigir revisão, como diz o adr-003. O SECURITY.md aponta para o reporte privado de vulnerabilidade do GitHub.
- **Tag `vX.Y.Z`, sem major móvel.** O `tagFormat` passa a `v${version}`. A tag `v1.0.0` aponta para o commit da `1.0.0`, que continua existindo, para o semantic-release achar a última versão.
- **Devbox alinhado ao CI.** O gitleaks vai para 8.23.3 e o actionlint para 1.7.12. O zizmor entra na 1.30.1, a mais nova do registry do devbox. O CI roda a 1.31.1.

## 3. Opções consideradas

### 3.1. Opção A: adotar as práticas convergentes e manter o layout

| Prós | Contras |
|---|---|
| Fecha as pendências de CICD-SEC-3 e CICD-SEC-5 | Um job e um lockfile a mais |
| Não muda o contrato com quem chama | A troca de tag exige criar `v1.0.0` |

**Adotada**, porque corrige as divergências sem mexer no layout.

### 3.2. Opção B: um repositório por action, para publicar no Marketplace

O Marketplace exige uma action por repositório, com o metadado na raiz.

| Prós | Contras |
|---|---|
| Listagem no Marketplace | Perde o SHA único como controle da cadeia |

**Rejeitada**, porque o adr-001 escolheu um SHA único, e publicar no Marketplace não é objetivo.

### 3.3. Opção C: repositório `.github` do dono com `workflow-templates/`

| Prós | Contras |
|---|---|
| Templates no botão "New workflow" | Workflow templates só existem em organizações, e o dono deste repositório não é uma |
| | O adr-004 já removeu as cópias |

**Rejeitada**, porque o recurso não se aplica.

### 3.4. Opção D: repositório `.github` do dono só para community health

| Prós | Contras |
|---|---|
| SECURITY.md e templates de issue herdados por todos os repositórios do dono | Mais um repositório para manter |

**Rejeitada**, porque o SECURITY.md e o CODEOWNERS deste repositório bastam.

### 3.5. Opção E: tag móvel `v1`

| Prós | Contras |
|---|---|
| Caller recebe correções sem trocar a referência | Contradiz o consumo por SHA |
| | Uma tag móvel não convive com releases imutáveis |

**Rejeitada**, porque o consumo é por SHA.

### 3.6. Opção F: referência `$/` no lugar de `./.github/workflows/`

| Prós | Contras |
|---|---|
| Sintaxe nova recomendada pelo zizmor | Pouco ganho com um único workflow |
| | O GHES não suporta a sintaxe |

**Rejeitada**. O `_ci.yaml` ignora o achado `self-repository` do zizmor na própria linha.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| semantic-release fixado na 23.0.0 | O `npm audit` aponta vulnerabilidades em dependências transitivas | O Dependabot propõe a atualização |
| Sem LICENSE | O código é público para leitura, sem permissão formal de reuso por terceiros | Decisão revisável a qualquer momento |
| Composite actions sem teste automatizado | Exercitá-las exige uma conta AWS e uma role OIDC | O zizmor audita o YAML delas |

## 5. Consequências

### 5.1. Positivas

- Os pins e o lockfile do release passam a ser atualizados por pull request do Dependabot.
- O título do pull request vira a mensagem do squash e decide o tipo da versão.

### 5.2. Negativas

- O próximo release depende da tag `v1.0.0`. Sem ela, o semantic-release recomeça na 1.0.0.
- Algumas proteções são configurações do repositório, fora do git: releases imutáveis, `sha_pinning_required`, reporte privado de vulnerabilidade e o check `Zizmor` no ruleset. O README lista o que ainda falta em Pendências conhecidas.

## 6. Referências

- [research-001-github-reusable-pipelines-organization.md](../research/research-001-github-reusable-pipelines-organization.md).
- [adr-001-layout.md](adr-001-layout.md) e [adr-003-release-without-commits.md](adr-003-release-without-commits.md): esta decisão os complementa.
- [GitHub Well-Architected: Actions security](https://wellarchitected.github.com/library/application-security/recommendations/actions-security/).
- [zizmor](https://docs.zizmor.sh/audits/).
