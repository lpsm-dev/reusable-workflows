---
date: 2026-10-17
---

# Organização de repositórios com pipelines reutilizáveis no GitHub

## 1. Pergunta e método

### 1.1 Pergunta

1. O que a documentação oficial do GitHub recomenda para um repositório que hospeda pipelines reutilizáveis (reusable workflows, custom actions, workflow templates)?
2. Como 20 repositórios reais da comunidade organizam esses ativos: onde ficam as actions, os reusable workflows e os templates, como versionam e publicam, como documentam e como testam as próprias actions?

### 1.2 Método

- Fontes primárias apenas: docs.github.com, github.blog, wellarchitected.github.com e o código dos próprios repositórios.
- Cada repositório foi clonado em modo somente leitura e inspecionado no HEAD da branch padrão. Nenhum script, build ou interpretador vindo desses repositórios foi executado.
- Critério de seleção: repositório público, com pelo menos um commit nos 90 dias anteriores a 2026-10-17 e com pipelines reutilizáveis como finalidade principal.
- As contagens são feitas por expressão regular sobre linhas `uses:` e sobre o bloco `permissions:` de nível superior. Elas medem presença, não qualidade. Declarações `permissions` no nível do job não entram na contagem.
- Fato observado e inferência são separados. Inferências levam o prefixo "Inferência:".
- Os SHAs da seção 4 são o HEAD observado em 2026-10-17. Eles fixam a evidência no tempo.

## 2. O que o GitHub recomenda

### 2.1 Reusable workflows

| Regra | Fonte |
|---|---|
| O arquivo fica em `.github/workflows/`. Subdiretórios não são suportados. | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| O gatilho é `on: workflow_call`, com `inputs` e `secrets` declarados. | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| O chamador usa `{owner}/{repo}/.github/workflows/{arquivo}@{ref}`. O `{ref}` pode ser SHA, tag ou branch. "Using the commit SHA is the safest option". | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| Dentro do mesmo repositório, `./.github/workflows/x` ou a referência `$/` (nova, indisponível no GHES) evitam repetir o `owner/repo`. | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| `secrets: inherit` é permitido dentro da mesma organização ou empresa. Os secrets só chegam ao workflow chamado diretamente. | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| As permissões do `GITHUB_TOKEN` só podem ser reduzidas pelo workflow chamado, nunca ampliadas. O runner é sempre avaliado no contexto do chamador. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |
| Não existe redirecionamento de nome para actions e reusable workflows quando o repositório é renomeado ou transferido. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |

### 2.2 Custom actions

| Regra | Fonte |
|---|---|
| Há três tipos: composite, JavaScript (`node20` ou `node24`) e Docker. O arquivo de metadados é `action.yml` ou `action.yaml`. | [Metadata syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/metadata-syntax) |
| Em composite actions, `shell` é obrigatório em cada passo `run`. Um passo pode usar `uses: owner/repo/subdir@ref` ou `$/`. | [Metadata syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/metadata-syntax) |
| Actions Docker rodam só em Linux e são mais lentas. Actions JavaScript são mais rápidas. | [About custom actions](https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions) |
| Uma action pública deve ter repositório próprio. Se ela convive com código de aplicação, o caminho recomendado é `.github/actions/<nome>`. | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |
| Evite URLs de API fixas. Use `GITHUB_API_URL` e variáveis equivalentes, para funcionar em GHES. | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |
| O README descreve entradas, saídas, secrets, variáveis de ambiente e um exemplo de uso. | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |

### 2.3 Reusable workflow ou composite action

A página conceitual compara os dois. Um composite não pode conter jobs e agrupa os logs de seus passos. Um reusable workflow é um ou mais jobs completos, com runner, permissões e secrets próprios. Composite actions podem ser aninhadas até 10 níveis em um workflow.
Fonte: [Reusing workflow configurations (conceitos)](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations).

O guia Well-Architected não compara os dois mecanismos (ver 2.11).

### 2.4 Workflow templates da organização

| Regra | Fonte |
|---|---|
| Os templates ficam no repositório `.github` da organização, na pasta `workflow-templates/`. | [Create workflow templates](https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates) |
| Cada template tem um `.yml` e um `.properties.json` com o mesmo nome. Metadados: `name` e `description` obrigatórios; `iconName`, `categories` e `filePatterns` opcionais. | [Create workflow templates](https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates) |
| O placeholder `$default-branch` é substituído pela branch padrão do repositório de destino. | [Create workflow templates](https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates) |
| A visibilidade do repositório `.github` define quem vê o template. Um template é cópia única, sem vínculo posterior com a origem. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |

Inferência: como o template é cópia, correções na origem não chegam aos repositórios que já o copiaram. Isso explica por que a comunidade usa templates apenas como ponto de partida e mantém a lógica em reusable workflows (seção 3).

### 2.5 Compartilhar actions e workflows privados

| Regra | Fonte |
|---|---|
| Em Settings, Actions, General, Access, o repositório privado ou interno escolhe quem pode usá-lo: nenhum, apenas o usuário, a organização ou (empresas) a empresa. | [Share with your organization](https://docs.github.com/en/actions/how-tos/reuse-automations/share-with-your-organization) |
| Repositórios privados chamam privados e públicos. Repositórios internos chamam internos e públicos. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |
| Aviso: colaboradores externos veem logs do workflow chamado indiretamente. O runner recebe um token com escopo, que expira em 1 hora. | [Share with your organization](https://docs.github.com/en/actions/how-tos/reuse-automations/share-with-your-organization) |
| As opções de Access e de actions permitidas são descritas na página de configurações do repositório. | [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository) |

### 2.6 Versionamento e release

| Regra | Fonte |
|---|---|
| Use um branch de release, uma tag semver e uma tag móvel de major (`v1`). Crie um novo major quando houver quebra de contrato. | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |
| Mantenha um workflow de teste e um de release, arquivos de community health e um badge de status. | [Release and maintain actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/release-and-maintain-actions) |
| Releases imutáveis travam a tag e os assets e geram uma atestação. Um nome de tag apagado não pode ser reutilizado. O fluxo recomendado é rascunho, anexar assets, publicar. | [Immutable releases](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases) |
| Para actions há duas formas: um release com tag imutável, ou tags git sem release (movíveis) para `v1` e `v1.1`. | [Using immutable releases and tags to manage your actions' releases](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/using-immutable-releases-and-tags-to-manage-your-actions-releases) |
| O recurso é opcional por repositório ou organização e vale apenas para novos releases (disponibilidade geral em 2025-10-28). | [Changelog: immutable releases GA](https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/) |

Observação: o exemplo da página de release usa uma action que move a tag `v1` por force push. Isso não funciona se a tag pertence a um release imutável (ver as duas últimas linhas da tabela).

### 2.7 Segurança

| Regra | Fonte |
|---|---|
| O lockfile de dependências de workflow (`.github/workflows/actions.lock`, gerado por `gh actions-lock`) é "the best measure" e substitui o pin por SHA. Cobre dependências transitivas. Não cobre as dependências de um reusable workflow chamado (elas ficam no lockfile do repositório dele). | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use), [Workflow dependency lockfiles](https://docs.github.com/en/actions/concepts/security/workflow-dependency-lockfiles) |
| O lockfile está em public preview desde 2026-10-14 (Free, Team e Enterprise Cloud). | [Changelog: lockfiles in public preview](https://github.blog/changelog/2026-10-14-github-actions-workflow-lockfiles-in-public-preview/) |
| Sem lockfile, fixe um SHA completo e confirme que ele não vem de um fork. Uma tag só é aceitável se você confia no criador. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| A política "Require actions to be pinned to a full-length commit SHA" cobre actions da organização e do GitHub, mas "Reusable workflows can still be referenced by tag". | [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository) |
| A política é configurável por API (campo `sha_pinning_required`) e aceita bloqueio por lista com `!`. | [REST: Actions permissions](https://docs.github.com/en/rest/actions/permissions), [Changelog: blocking and SHA pinning](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/) |
| As listas de permitir e bloquear aceitam curingas, `!` e no máximo 1000 entradas. | [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository) |
| O `GITHUB_TOKEN` padrão pode ser restrito a leitura. Declare o mínimo de permissões por workflow ou job. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| Passe entradas não confiáveis por variável de ambiente, não por interpolação de expressão em `run`. Evite `pull_request_target` e `workflow_run` com checkout de código não confiável. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| Proteja os arquivos de workflow com CODEOWNERS. Use OIDC em vez de credenciais de longa duração. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| Dependabot não alerta sobre actions fixadas por SHA, ignora referências locais e atualiza o comentário de versão na mesma linha. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use), [Ecossistemas suportados](https://docs.github.com/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories) |
| Complementos recomendados: code scanning, OpenSSF Scorecards e dependency review. | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| A proteção "Require lockfile" aplica o lockfile por política. A página também registra uma política padrão que bloqueia `pull_request_target` em repositórios públicos, com aplicação em 2026-11-02. | [Control workflow execution](https://docs.github.com/en/actions/how-tos/administer/control-workflow-execution) |
| O roadmap de segurança de 2026 cita lockfiles, secrets com escopo, herança de secrets em reusable workflows, firewall de egress e execução guiada por política. É roadmap, o estado atual de cada item não foi verificado. | [2026 security roadmap](https://github.blog/news-insights/product-news/whats-coming-to-our-github-actions-2026-security-roadmap/) |

### 2.8 Marketplace

| Regra | Fonte |
|---|---|
| O repositório é público e tem um único arquivo de metadados de action na raiz. Actions em subpastas não são listadas. | [Publish in GitHub Marketplace](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/publish-in-github-marketplace) |
| O `name` da action é único no Marketplace. A autenticação em dois fatores é exigida para publicar. | [Publish in GitHub Marketplace](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/publish-in-github-marketplace) |
| O repositório deve conter apenas a action. | [Publish in GitHub Marketplace](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/publish-in-github-marketplace) |
| Reusable workflows não podem ser publicados no Marketplace. Composite actions podem. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |

### 2.9 Limites dos reusable workflows

| Limite | Fonte |
|---|---|
| Até 10 níveis de aninhamento (chamador mais 9). Loops não são permitidos. | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| Até 50 reusable workflows únicos por arquivo de workflow, incluindo as árvores aninhadas. | [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations) |
| Histórico do limite: antes 4 níveis e 20 workflows; em 2025-11-06 passou a 10 e 50. | [Changelog 2025-11-06](https://github.blog/changelog/2025-11-06-new-releases-for-github-actions-november-2025/) |

### 2.10 Práticas gerais do repositório

| Regra | Fonte |
|---|---|
| Arquivos de community health padrão (CONTRIBUTING, SECURITY, templates de issue) vêm de um repositório `.github` público da organização. A precedência é `.github/`, raiz, `docs/`. Não existe LICENSE padrão herdável. | [Creating a default community health file](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file) |
| O CODEOWNERS pode ficar em `.github/`, na raiz ou em `docs/`. A última regra que casa vence. Donos precisam de acesso de escrita. O próprio arquivo CODEOWNERS deve ter dono. | [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) |
| Rulesets: até 75 por repositório, em camadas, vence a mais restritiva. Aplicam-se a branches e tags, com listas de bypass. São a alternativa às branch protection rules. | [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets) |
| O README de uma action documenta entradas, saídas e exemplo (ver 2.2). | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |

### 2.11 GitHub Well-Architected

Duas páginas foram lidas. Nenhuma compara composite action com reusable workflow.

| Regra | Fonte |
|---|---|
| Uma organização dedicada funciona como marketplace interno. Repositórios por função (`security-workflows`, `deployment-workflows`, `build-workflows`, `testing-workflows`, `utility-actions`). Nome `[categoria]-[função]-[escopo]-[linguagem/plataforma]`. | [Scaling Actions reusability](https://wellarchitected.github.com/library/collaboration/recommendations/scaling-actions-reusability/) |
| Use semver. Aplique uma base de rulesets, CODEOWNERS e Dependabot. Mantenha um repositório índice, Topics, Pages e custom properties. Versione workflows relacionados juntos ou separados conforme o acoplamento. Revise a cada trimestre. | [Scaling Actions reusability](https://wellarchitected.github.com/library/collaboration/recommendations/scaling-actions-reusability/) |
| Declare `permissions: {}` no nível do workflow e dê permissões por job. Fixe SHA com comentário de versão, ou tag de release imutável. Use OIDC com as claims `sub` e `job_workflow_ref`. Mantenha a lista de actions permitidas como código. | [Actions security](https://wellarchitected.github.com/library/application-security/recommendations/actions-security/) |

Divergência entre fontes: esta página diz que a política de SHA cobre "reusable workflow references". A página de configurações do repositório diz que reusable workflows ainda podem ser referenciados por tag. Esta pesquisa não resolve a divergência (seção 7).

## 3. Padrões encontrados na comunidade

Os números abaixo vêm da tabela da seção 4 e são detalhados na seção 5.

### 3.1 Cinco formas de organizar

| Forma | Repositórios | Característica |
|---|---|---|
| Monorepo de actions | elastic, chainguard, Kong, Homebrew | Cada pasta é uma action. Sem reusable workflows. Os workflows do repositório fazem dogfooding de `uses: ./pasta`. |
| Monorepo híbrido | grafana, bitwarden, smartcontractkit, kubewarden, slsa | Actions em pastas próprias e reusable workflows em `.github/workflows/`. |
| Só reusable workflows | rapidsai, equinor, OpenAstronomy, jenkins, actions/reusable-workflows | Sem actions próprias fora de `.github/`. Um repositório separado guarda as actions (rapidsai). |
| Repositório `.github` da organização | nextcloud, cloudposse, smartcontractkit | Templates em `workflow-templates/` somados a workflows reutilizáveis ou arquivos de community health. |
| Um repositório por domínio | entur | `gha-docker`, `gha-terraform`, `gha-helm`, `gha-security`, `gha-meta`. |

Os demais (ansible, canonical, actions/starter-workflows) não se encaixam limpamente: ansible é um hub de práticas, canonical combina workflows e actions internas, starter-workflows é um catálogo de templates.

### 3.2 Padrões recorrentes

- Reusable workflows planos em `.github/workflows/`, como o GitHub exige. Quando o repositório mistura workflows chamáveis e internos, a separação é por prefixo (`reusable-`, `shared-`, `_`, `self-`) ou só pela presença de `workflow_call`. Não há convenção única.
- Actions na raiz (`<nome>/action.yml`) ou em `actions/<nome>/`. Namespaces aninhados aparecem em elastic (`aws/auth`).
- Tag móvel de major em 6 repositórios, criada por workflow de release. Tags por componente em 3 (monorepos com versionamento independente).
- Referência externa fixada por SHA com comentário de versão na maioria (14 de 20).
- Testes das actions por workflows `test-*` que chamam `uses: ./<action>` (grafana, bitwarden, elastic, chainguard, Kong).
- Templates como cópia de ponto de partida, nunca como mecanismo de reuso. Nextcloud sincroniza as cópias por cron.
- Slsa-github-generator contraria a recomendação de SHA por exigência do verificador: o chamador deve referenciar `@vX.Y.Z` (README do projeto).

## 4. Os 20 repositórios

Os dois blocos de tabela seguem a mesma ordem. O link da coluna Repositório aponta para o caminho principal no SHA observado. O SHA é o HEAD da branch padrão em 2026-10-17.

### 4.1 Estrutura

| # | Repositório | Branch | SHA observado (HEAD) | Padrão | Reusable workflows | Custom actions | Templates |
|---|---|---|---|---|---|---|---|
| 1 | [grafana/shared-workflows](https://github.com/grafana/shared-workflows/tree/cdfa828a8c3148777e8b91d326ff2ed355be4631/actions) | main | `cdfa828a8c3148777e8b91d326ff2ed355be4631` | Monorepo híbrido | 4 de 34 workflows (`.github/workflows/`) | 38 em `actions/<nome>/` (37 composite) | Não |
| 2 | [bitwarden/gh-actions](https://github.com/bitwarden/gh-actions/tree/cfbd3f2d657c12aad532639be10d79414b7af957) | main | `cfbd3f2d657c12aad532639be10d79414b7af957` | Híbrido, actions na raiz | 16, 14 com prefixo `_` | 31 em `<nome>/` (28 composite) | Sim, `.github/templates/workflow-templates/` e `templates/` (cópia e adaptação) |
| 3 | [elastic/oblt-actions](https://github.com/elastic/oblt-actions/tree/bfa42c89bb87e95ff02bc076a1cbdac4be88a92b) | main | `bfa42c89bb87e95ff02bc076a1cbdac4be88a92b` | Monorepo de actions com namespaces | 0 de 64 | 57 (54 composite) | Não |
| 4 | [chainguard-dev/actions](https://github.com/chainguard-dev/actions/tree/53668650c25af6e8864f1d1ddaa69ed4db4cdf09) | main | `53668650c25af6e8864f1d1ddaa69ed4db4cdf09` | Monorepo de actions na raiz | 0 | 48 (45 composite) | Não |
| 5 | [Kong/public-shared-actions](https://github.com/Kong/public-shared-actions/tree/ec4458822419049fade832603fef9a9874af877a) | main | `ec4458822419049fade832603fef9a9874af877a` | Actions por categoria | 0 | 16 composite em `code-build-actions/`, `security-actions/` e outras | Não |
| 6 | [Homebrew/actions](https://github.com/Homebrew/actions/tree/4790763c0a3ba4036f72634dc079c4a7dfcd4878) | main | `4790763c0a3ba4036f72634dc079c4a7dfcd4878` | Actions na raiz, "every directory is a separate Action" | 0 | 22 (9 composite, 13 node24, `node_modules` versionado) | Não |
| 7 | [smartcontractkit/.github](https://github.com/smartcontractkit/.github/tree/c541a0c10164ae4648b380ce8af74821fbc6e3ba/workflows) | main | `c541a0c10164ae4648b380ce8af74821fbc6e3ba` | Híbrido, fonte por componente em `workflows/<nome>/` com cópia gerada | 9 em `.github/workflows/` | 120 em `actions/` (89 composite, 3 docker, 20 node24) | Não |
| 8 | [kubewarden/github-actions](https://github.com/kubewarden/github-actions/tree/e12c3122429274f1c7abfcc9adcab0def5391176) | main | `e12c3122429274f1c7abfcc9adcab0def5391176` | Híbrido, actions na raiz | 15 (`reusable-*.yml`) | 17 composite | Não |
| 9 | [rapidsai/shared-workflows](https://github.com/rapidsai/shared-workflows/tree/df1ca690349f5421de139f558249821b94f616b0/.github/workflows) | main | `df1ca690349f5421de139f558249821b94f616b0` | Só workflows (actions em outro repositório) | 27 de 27 | 2 locais em `.github/actions/` | Não |
| 10 | [equinor/ops-actions](https://github.com/equinor/ops-actions/tree/def1359ccd977da6f0720b22328ba6ac02b380ae/.github/workflows) | main | `def1359ccd977da6f0720b22328ba6ac02b380ae` | Só workflows por tecnologia | 24 de 29 | 0 | Não |
| 11 | [OpenAstronomy/github-actions-workflows](https://github.com/OpenAstronomy/github-actions-workflows/tree/e25a8c5d18e2499bdc4381670917b73e3107dca1/.github/workflows) | main | `e25a8c5d18e2499bdc4381670917b73e3107dca1` | Só workflows | 3 (`tox.yml`, `publish.yml`, `publish_pure_python.yml`) | 0 | Não |
| 12 | [ansible/team-devtools](https://github.com/ansible/team-devtools/tree/a8b84b38191f191f6ec2ae1e2096b4b55ca24e92/.github/workflows) | main | `a8b84b38191f191f6ec2ae1e2096b4b55ca24e92` | Hub de práticas e workflows | 10 (snake_case) | 0 | Não |
| 13 | [canonical/operator-workflows](https://github.com/canonical/operator-workflows/tree/1305365b01750a3ab472fd285ec6e1902b5377bb/.github/workflows) | main | `1305365b01750a3ab472fd285ec6e1902b5377bb` | Workflows e actions internas | 17 (snake_case, `.yaml`) | 6 em `internal/*/` (node20) | Não |
| 14 | [jenkins-infra/github-reusable-workflows](https://github.com/jenkins-infra/github-reusable-workflows/tree/5c940cd850897d1b6643c1d49c552ae54b22a290/.github/workflows) | main | `5c940cd850897d1b6643c1d49c552ae54b22a290` | Workflows pequenos, prefixo `self-` para internos | 3 | 0 | Não |
| 15 | [nextcloud/.github](https://github.com/nextcloud/.github/tree/bbe630e1ba9b688f6cf2e02c188adbeae8902e3a/workflow-templates) | master | `bbe630e1ba9b688f6cf2e02c188adbeae8902e3a` | `.github` da organização com templates | 0 | 0 | Sim, 39 `.properties.json` em `workflow-templates/` |
| 16 | [cloudposse/.github](https://github.com/cloudposse/.github/tree/f9bb2cc3329d164ab3b4a612a086930faf854718/.github/workflows) | main | `f9bb2cc3329d164ab3b4a612a086930faf854718` | `.github` da organização, híbrido | 16 (`shared-*.yml`) | 1 local (`.github/actions/verify-sha-pinning`) | Sim, `workflow-templates/` (7 `.properties.json`) |
| 17 | [actions/starter-workflows](https://github.com/actions/starter-workflows/tree/e3c451d60f119b71caebf13c98ac45da6e15b4b7) | main | `e3c451d60f119b71caebf13c98ac45da6e15b4b7` | Catálogo oficial de templates | 0 | 0 | Sim, `<categoria>/` com `<categoria>/properties/*.properties.json` |
| 18 | [actions/reusable-workflows](https://github.com/actions/reusable-workflows/tree/d468c63c53c1184242904d1a3ac74fd1081f36c8/.github/workflows) | main | `d468c63c53c1184242904d1a3ac74fd1081f36c8` | Oficial, workflows para desenvolver actions | 5 | 0 | Não (há `reusable-configurations/` com eslint e prettier) |
| 19 | [slsa-framework/slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator/tree/bb91a05077afa6601a3d7538c4cbbdbf0abe7ed9/.github/workflows) | main | `bb91a05077afa6601a3d7538c4cbbdbf0abe7ed9` | Híbrido, builders e generators | 10 | 36 em `actions/<ecossistema>/` mais internas em `.github/actions/` | Não |
| 20 | [entur/gha-docker](https://github.com/entur/gha-docker/tree/dcdc76ce2d251de20f35a92c566d8fe99036e03e/.github/workflows) | main | `dcdc76ce2d251de20f35a92c566d8fe99036e03e` | Um repositório por domínio | 3 (`lint.yml`, `build.yml`, `push.yml`) | 2 internas em `.github/actions/` | Não |

### 4.2 Versionamento, docs, testes e segurança

| # | Repositório | Versionamento | Docs | Testes | Segurança |
|---|---|---|---|---|---|
| 1 | grafana/shared-workflows | release-please (manifest). Tags `<action>/vX.Y.Z` mais `<action>/vX` e `<action>/vX.Y` móveis. Releases imutáveis desde 2026-05-04 (README do projeto). | README em 38 de 38 actions. `check-action-docs.yaml` com action-docs. `.md` ao lado de cada reusable workflow. | 17 workflows `test-*` com filtro de caminho | zizmor (via `reusable-zizmor.yml`), actionlint (pre-commit), scorecards, harden-runner, `permissions: {}`. CODEOWNERS. 190 SHA, 0 tags |
| 2 | bitwarden/gh-actions | 3 tags (`v0`, `v0.1`, `v0.2`). Referências internas em `@main` (50). | README em 27 de 31 actions | 29 workflows `test-*` | actionlint, Renovate, CODEOWNERS, SECURITY.md. 127 SHA, 50 branch |
| 3 | elastic/oblt-actions | Semver global `v1.42.1` com `v1` e `v0` móveis (`create-major-tag.yml`, force push). release-drafter. | README em 57 de 57. Catálogo por namespace. CONTRIBUTING em `docs/`. | 52 workflows `test-*` com `uses: ./aws/auth` | actionlint (pre-commit), CODEOWNERS por caminho. 241 tags, 16 SHA |
| 4 | chainguard-dev/actions | Tag global `vX.Y.Z` (v1.6.41), sem major móvel. `release.yaml` semanal ou manual (major, minor, patch, dry_run). | README em 42 de 48 | 17 workflows `test-*` | actionlint, zizmor, harden-runner com bloqueio de egress, `permissions: {}`. 111 SHA. Sem CODEOWNERS observado |
| 5 | Kong/public-shared-actions | lerna com versionamento independente e commits convencionais. Tags `scan-docker-image@6.1.1` (sem `v`), além de v1 e v2 legadas. | README em 11 de 16. README recomenda `@<SHA> # v4.0.1` e config Renovate compartilhada. | Workflows do repositório fazem dogfooding de `./security-actions/...` | CODEOWNERS, SECURITY.md. 88 SHA, 1 tag |
| 6 | Homebrew/actions | CalVer `YYYY.MM.DD.N`, sem tag móvel. Release semanal agendado com 24 h de bake time e release com notas geradas. | README em 19 de 22 | `test.yml` (unittest Python, checagem de vendorização, `tsc`) | zizmor e actionlint (`actionlint.yml`), CODEOWNERS. 38 SHA |
| 7 | smartcontractkit/.github | changesets e PR "Version packages". Tags `apidiff-go/v1` (major móvel) e `crib-deploy-environment@8.6.0`. | README em 110 de 120. CHANGELOG por componente. | vitest com `__fixtures__`, nx, lefthook | actionlint (`.github/actionlint.yaml`), CODEOWNERS. 132 SHA, 153 tags, 60 outros |
| 8 | kubewarden/github-actions | Tags semver v2 em diante, v1 como branch. release-drafter e `ghrelease.yml`. Os workflows referenciam as próprias actions por SHA completo, atualizado antes da tag (documentado). | README em 5 de 17 | Nenhum workflow de teste observado | CODEOWNERS. 116 SHA |
| 9 | rapidsai/shared-workflows | CalVer, tags como `v26.10.00a`. Exemplo do README usa `@main`. | README mais `MATRIX_GUIDELINES.md` | Existem `ci/maven-publish/test_*.sh`; a execução em CI não foi verificada | zizmor (config), actionlint, yamllint, pre-commit, CODEOWNERS, SECURITY.md. 61 SHA, 63 branch |
| 10 | equinor/ops-actions | release-please (manifest). Tags globais `v9.43.2` (197 tags), sem major móvel. | `docs/workflows/<nome>.md` (mkdocs) e `docs/best-practices.md` | Sem testes de execução observados; há lint | zizmor (`zizmor-codeql`), CODEOWNERS, SECURITY.md. `permissions: {}` no topo mais permissões por job. 72 SHA |
| 11 | OpenAstronomy/github-actions-workflows | Tags v1, v2, v3 móveis (`update_tag.yml` com nowactions/update-majorver) mais semver (v3.1.1). | Sphinx no Read the Docs (`docs/source/*.rst`) e README | `test_*.yml` chamam `./.github/workflows/tox.yml` sobre o fixture `packages/subpackage` | Só comentários `# zizmor: ignore`. 45 SHA. Sem CODEOWNERS observado |
| 12 | ansible/team-devtools | CalVer `v26.4.0` (17 tags). Consumidores usam SHA com `# main`. release-drafter. | `docs/guides/gha.md` (nomes, job final `check` com alls-green) e `calver.md` | `test.yml` roda o tox do próprio repositório (validação) | scorecard, CODEOWNERS. 50 SHA |
| 13 | canonical/operator-workflows | Sem tags. README documenta cada workflow com ref `@main`. | README por workflow | `workflow_test.yaml`, `workflow_simple_test.yaml`, `charmbuild_test.yaml`, `charmbuild/tests` | CODEOWNERS. 4 SHA, 75 tags, 15 outros |
| 14 | jenkins-infra/github-reusable-workflows | Tags `v1.8.4` e `v1` móvel (`self-update-major-tag.yml`). | README declara o prefixo `self-` para workflows não reutilizáveis | Nenhum observado | 1 SHA, 6 tags. Sem CODEOWNERS observado |
| 15 | nextcloud/.github | Sem tags. `sync-workflow-templates.yml` (cron semanal) recopia os templates, com suporte a `.patch`. | Community health: CONTRIBUTING, SECURITY, templates de issue e PR, `profile/README.md`, REUSE.toml, AI_POLICY.md | Apenas validação (zizmor-action sobre workflows e templates) | zizmor-action, SECURITY.md. 24 SHA. Sem CODEOWNERS observado |
| 16 | cloudposse/.github | Tags `v0.180.0` e `0.173.0` (formatos misturados, 193 tags) | README gerado de `README.yaml` via build-harness. Community health presentes. | `verify-sha-pinning.yml` valida cobertura e deriva de pins (validação) | Renovate, CODEOWNERS, SECURITY.md. 74 SHA, 2 tags, 15 outros, 10 docker |
| 17 | actions/starter-workflows | Sem tags | CONTRIBUTING exige pin por SHA fora da organização `actions` | `validate-data.yaml` roda `script/validate-data` (validação) | CODEOWNERS. 15 tags |
| 18 | actions/reusable-workflows | Sem tags. Consumo por `@main`. | README | Nenhum observado | CODEOWNERS, SECURITY.md. 14 SHA |
| 19 | slsa-framework/slsa-github-generator | `RELEASE.md` (runbook manual), tags `vX.Y.Z` e `-rc.N`. O chamador deve usar `@vX.Y.Z` (exigência do verificador). | README por ecossistema (14 de 36 actions com README) | Workflows `pre-submit.*` de ponta a ponta | actionlint (`pre-submit.lint.yml`), Renovate, CODEOWNERS, SECURITY.md. 126 SHA, 93 branch |
| 20 | entur/gha-docker | Tags `v1.13.x`, `v1` e `vX.Y` móveis. Release via `gha-meta/release.yml` (wrapper do release-please). CHANGELOG. | `README-<workflow>.md` gerado por `gha-meta/.github/workflows/auto-doc.yml@v1` | `ci.yml` testa os workflows com um `fixture/` de Dockerfiles | Dependabot, CODEOWNERS. 26 SHA, 12 tags |

Notas:

- A coluna Segurança lista a presença de ferramenta e a distribuição das linhas `uses:` (SHA, tag, branch). As contagens de `uses:` incluem autorreferências.
- Dependabot ou Renovate foi observado nos 20 repositórios (arquivo de configuração).
- O Padrão e o caminho são do HEAD citado. Nada foi verificado sobre o histórico.

### 4.3 Notas por repositório

1. **grafana/shared-workflows.** Monorepo híbrido. A maior parte do valor está nas 38 actions, cada uma com README e versão própria (release-please). O README do projeto manda fixar SHA com comentário `# foo/v1.2.3` e usar caminho relativo para actions irmãs.
2. **bitwarden/gh-actions.** O prefixo `_` marca os workflows chamáveis (14 de 16), o oposto do prefixo `_` deste repositório. Só 3 tags existem; o consumo interno é por `@main`.
3. **elastic/oblt-actions.** Só actions. Um workflow cria o major móvel a cada release publicado. Consumidores usam `@v1`, o que explica as 241 referências por tag.
4. **chainguard-dev/actions.** Release semanal automatizado de uma tag global. Sem major móvel, então consumidores fixam SHA ou a tag exata.
5. **Kong/public-shared-actions.** Agrupa por categoria e versiona cada action de forma independente com lerna. As tags não levam `v`.
6. **Homebrew/actions.** CalVer nunca movido. As actions node24 versionam `node_modules`, e o teste confere a vendorização.
7. **smartcontractkit/.github.** Contorna o limite de pasta plana: a fonte de cada workflow vive em `workflows/<nome>/` com `package.json` e `CHANGELOG.md`, e uma cópia marcada "GENERATED FILE - DO NOT EDIT" é sincronizada para `.github/workflows/`.
8. **kubewarden/github-actions.** Documenta que os workflows chamam as próprias actions por SHA completo, atualizado antes da tag. É o único caso observado que descreve essa dependência circular.
9. **rapidsai/shared-workflows.** Só workflows, todos com `workflow_call` e sem prefixo. As composite actions ficam em `rapidsai/shared-actions`, consumido por `@main` (a existência desse repositório não foi verificada à parte).
10. **equinor/ops-actions.** Workflows reutilizáveis e internos convivem na mesma pasta, separados apenas pela ausência de `workflow_call`. `docs/best-practices.md` reúne as regras de segurança do projeto.
11. **OpenAstronomy/github-actions-workflows.** Documentação em Sphinx. Os testes chamam o próprio workflow local contra um fixture.
12. **ansible/team-devtools.** Um comentário em `release.yml` diz que o trusted publishing do PyPI não funciona com workflow compartilhado ("for reference only").
13. **canonical/operator-workflows.** Sem tags: o consumo é por `@main`. Tem autotestes dos workflows.
14. **jenkins-infra/github-reusable-workflows.** Pequeno. O README declara o prefixo `self-` para workflows que não são reutilizáveis.
15. **nextcloud/.github.** Repositório `.github` da organização com 39 templates e sincronização por cron. Não tem reusable workflows.
16. **cloudposse/.github.** Combina templates, workflows `shared-*` e uma action local que verifica a cobertura de pins por SHA. Tags em dois formatos.
17. **actions/starter-workflows.** Referência oficial de templates. As propriedades ficam em `<categoria>/properties/`, não ao lado do `.yml`.
18. **actions/reusable-workflows.** Referência oficial de reusable workflows para desenvolver actions. Consumo por `@main`, sem tags.
19. **slsa-framework/slsa-github-generator.** Exige `@vX.Y.Z` por causa do verificador de proveniência (README do projeto). Isso contraria a recomendação de SHA da seção 2.7 e está registrado no issue 12 do slsa-verifier.
20. **entur/gha-docker.** A documentação é gerada por um workflow reutilizável de outro repositório do mesmo grupo (`gha-meta`).

Repositórios vizinhos (`entur/gha-meta`, `gha-terraform`, `gha-helm`, `gha-security`) foram vistos, mas não entram na contagem.

## 5. Convergências e divergências

As contagens vêm da tabela 4.1 e 4.2 e valem para os 20 repositórios.

### 5.1 Convergências

| Tema | Contagem | Quais |
|---|---|---|
| Configuração de Dependabot ou Renovate | 20 de 20 | todos |
| CODEOWNERS | 16 de 20 | todos exceto chainguard, OpenAstronomy, jenkins e nextcloud |
| Maioria das referências externas fixada por SHA | 14 de 20 | todos exceto elastic, smartcontractkit, rapidsai, canonical, jenkins e starter-workflows |
| `permissions` de nível superior em todos os workflows | 5 de 20 | elastic, chainguard, Homebrew, ansible e nextcloud (apenas regex de nível superior) |
| Possui reusable workflows (`workflow_call`) | 14 de 20 | os 6 sem são elastic, chainguard, Kong, Homebrew, nextcloud e starter-workflows |
| Actions fora de `.github/` | 10 de 20 | grafana, bitwarden, elastic, chainguard, Kong, Homebrew, smartcontractkit, kubewarden, slsa e canonical |
| Actions só em `.github/actions` | 3 de 20 | rapidsai, cloudposse e entur |
| Sem actions próprias | 7 de 20 | equinor, OpenAstronomy, ansible, jenkins, nextcloud, starter-workflows e actions/reusable-workflows |
| Testes que executam ou exercitam as peças | 11 de 20 | grafana, bitwarden, elastic, chainguard, Kong, Homebrew, smartcontractkit, OpenAstronomy, canonical, slsa e entur |
| actionlint verificado | 8 de 20 | grafana, bitwarden, elastic, chainguard, Homebrew, smartcontractkit, rapidsai e slsa |
| zizmor como ferramenta | 6 de 20 | grafana, chainguard, Homebrew, rapidsai, equinor e nextcloud |

### 5.2 Divergências

| Tema | Contagem | Detalhe |
|---|---|---|
| Templates | 4 de 20 | nextcloud e cloudposse usam `workflow-templates/` oficial; starter-workflows usa `<categoria>/properties`; bitwarden usa caminhos próprios e cópia manual |
| SECURITY.md no próprio repositório | 8 de 20 | bitwarden, Kong, rapidsai, equinor, nextcloud, cloudposse, actions/reusable-workflows e slsa |
| Sem tags | 4 de 20 | canonical, nextcloud, starter-workflows e actions/reusable-workflows |
| Dos 16 com tags, prefixo `v` como padrão | 12 de 16 | 2 usam tag sem `v` (Kong, Homebrew) e 2 misturam os formatos (smartcontractkit, cloudposse) |
| Tag móvel de major ou minor mantida | 6 de 20 | elastic, OpenAstronomy, jenkins, entur; grafana e smartcontractkit por action |
| Tags por componente | 3 de 20 | grafana, smartcontractkit e Kong |
| CalVer | 3 de 20 | Homebrew, ansible e rapidsai |
| Ferramenta de release verificada | release-please 3, changesets 1, lerna 1, release-drafter 2, script agendado 2, runbook manual 1 | release-please: grafana, equinor, entur (via gha-meta). release-drafter: elastic, kubewarden. Script agendado: chainguard, Homebrew. Os demais não foram verificados. |
| Testes só de lint ou validação | 5 de 20 | starter-workflows, nextcloud, cloudposse, equinor e ansible |
| Sem testes observados | 4 de 20 | kubewarden, rapidsai, jenkins e actions/reusable-workflows |
| README por action (nos 11 repositórios com actions próprias fora de `.github`) | grafana 38 de 38, elastic 57 de 57, entur 2 de 2, chainguard 42 de 48, smartcontractkit 110 de 120, bitwarden 27 de 31, Homebrew 19 de 22, Kong 11 de 16, slsa 14 de 36, kubewarden 5 de 17, canonical 0 de 6 | Contagem sobre actions com README na própria pasta |
| Prefixo do arquivo chamável | sem convenção única | `reusable-` (kubewarden), `shared-` (cloudposse), `_` (bitwarden), `self-` para o interno (jenkins); equinor, grafana e rapidsai não usam prefixo |

Leitura (Inferência): os repositórios com mais disciplina de supply chain (grafana, chainguard, Homebrew, equinor) também têm `permissions: {}` ou equivalente, SHA em quase todas as referências e ferramentas de análise. Os que priorizam consumo simples (elastic, jenkins, OpenAstronomy) preferem tag móvel de major.

## 6. Comparação com este repositório

Esta seção compara. Ela não propõe mudanças de código. O repositório é `lpsm-dev/reusable-workflows`, no commit `4c3000c33970d51eba3d8493aa9e32e32e8b0dee`. Fatos sobre ele vêm de `README.md`, dos ADRs 0001 a 0004 em `docs/adrs/` e dos workflows em `.github/workflows/`.

### 6.1 Onde já segue o recomendado

| Prática | Evidência neste repositório | Fonte da regra |
|---|---|---|
| Reusable workflow chamável plano em `.github/workflows/` | `.github/workflows/gitleaks.yaml` com `on: workflow_call` | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| Consumidores fixam SHA completo | README, seção de uso | [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) |
| Actions de terceiros por SHA com comentário de versão | `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1  # v7.0.1` e `persist-credentials: false` | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| `GITHUB_TOKEN` somente leitura por padrão e escrita só no job de release | `permissions: contents: read` e ADR 0004 | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| Binário baixado com verificação de SHA256 | `gitleaks.yaml` | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |
| README por componente com entradas, saídas e exemplo, gerado por action-docs | ADR 0002, tarefa `action:docs` | [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions) |
| Ruleset na branch principal e release sem commit na `main` | ADR 0004 | [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets) |
| Lint dos workflows (actionlint e yamllint) | `_check-workflows.yaml` | [Secure use](https://docs.github.com/en/actions/reference/security/secure-use) |

### 6.2 Onde diverge ou não há evidência

| Tema | Este repositório | Referência oficial | Comunidade (de 20) |
|---|---|---|---|
| Repositório por action | Um repositório com três superfícies (ADR 0001 rejeitou um repositório por action para ter um SHA único como controle do CICD-SEC-3) | Action pública em repositório próprio; Marketplace exige um metadado de action na raiz e o repositório só com a action | 10 têm actions fora de `.github/`, quase todos em monorepo |
| Formato da tag | Tag sem `v` (`tagFormat: ${version}`), única tag `1.0.0`, sem major móvel | Tag semver mais `v1` móvel | 12 de 16 usam `v` como padrão; 2 usam tag sem `v`; 6 mantêm major móvel |
| `permissions` | `contents: read` no nível do workflow | Well-Architected: `permissions: {}` no workflow e permissões por job | grafana, chainguard e equinor usam `{}` no topo |
| Política `sha_pinning_required` | Desligada, registrada no README como lacuna conhecida | Política existe; reusable workflows ainda podem ser referenciados por tag | Não observável por git |
| CODEOWNERS | Não encontrado na árvore | Recomendado para workflows e pelo Well-Architected | 16 de 20 têm |
| Dependabot ou Renovate | Não encontrado na árvore | Dependabot atualiza actions e o comentário de versão | 20 de 20 têm |
| SECURITY.md e LICENSE | Não encontrados na árvore | Community health vem de um `.github` público da organização; LICENSE não é herdável | 8 de 20 têm SECURITY.md próprio |
| Testes das composite actions | Não encontrados | Workflow de teste recomendado em "Release and maintain actions" | 11 de 20 exercitam as peças |
| Releases imutáveis | Estado não registrado no repositório | Recomendado para actions | grafana documenta; os demais não são verificáveis |
| Dependências do release | semantic-release 23.0.0 instalado via npm, versões fixas, sem lockfile; Node vem de `lts/*` | Lockfile é a medida mais forte | Não verificado nos 20 |
| Convenção de prefixo | `_` marca o interno | Sem regra oficial | bitwarden usa `_` para o chamável (oposto); jenkins usa `self-` para o interno |
| Documentação de workflows | `docs/workflows/<nome>/` com README | Sem regra oficial | equinor usa `docs/workflows/`; grafana põe `.md` ao lado do `.yml`; entur usa `README-<workflow>.md` na raiz |

### 6.3 Inferências

- Inferência: sem Dependabot ou Renovate, os pins por SHA do repositório dependem de atualização manual. Nenhum arquivo de configuração foi encontrado na árvore.
- Inferência: a política `sha_pinning_required` não cobriria a referência por tag a reusable workflows, então ligar a política não substitui a orientação de SHA que o README dá aos consumidores. O lockfile (public preview desde 2026-10-14) é descrito pela documentação como melhor medida para quem consome, e o texto do README sobre SHA continua válido para quem não o adota.
- Inferência: a referência `$/` poderia substituir `./.github/workflows/gitleaks.yaml` em `_ci.yaml`. OpenAstronomy e entur chamam o workflow local nos próprios testes, o mesmo padrão. A referência `$/` não existe no GHES.
- Inferência: a abordagem de smartcontractkit (fonte por componente mais cópia gerada) mostra uma forma de versionar cada workflow à parte apesar da pasta plana, mas só vale a pena se a versão por workflow for necessária. O ADR 0001 escolheu uma versão única.
- Inferência: kubewarden documenta que actions chamadas pelos próprios workflows devem ser atualizadas por SHA antes da tag. O mesmo risco circular existe aqui, onde os workflows internos chamam as composite actions por caminho local.
- Inferência: `lpsm-dev/.github` não foi encontrado de forma anônima. Pode ser privado ou inexistente, então herança de community health não foi verificada.

## 7. Lacunas

| Lacuna | Efeito |
|---|---|
| As páginas de configuração de Actions em nível de organização e "Disabling or limiting GitHub Actions for your organization" não foram abertas. Só a página do repositório e o trecho da API REST. | A seção 2.7 pode omitir detalhes de políticas de organização. |
| O lockfile foi lido na documentação e no changelog, sem teste. Elegibilidade em GHES e planos além do changelog não foi checada. | O estado prático do recurso é não verificado. |
| O roadmap de segurança de 2026 (secrets com escopo, firewall de egress) é roadmap. | O estado atual de cada item é não verificado. |
| Imutabilidade de releases, GitHub Releases e listagens no Marketplace dos 20 repositórios não são verificáveis por git. | Só grafana documenta o estado no próprio README. |
| A evidência é do HEAD. As contagens são por regex sobre `uses:` e `permissions:` de nível superior. | Permissões no nível do job não entram. As contagens medem presença, não qualidade. |
| Inconsistência: transferência de repositório. A página do Marketplace diz que há redirecionamento. A referência de reusable workflows diz que não há. | Não foi resolvida. |
| Inconsistência: a política de SHA cobre reusable workflows? A página de configurações diz que a tag ainda é aceita. O Well-Architected diz que as referências são cobertas. | Não foi resolvida. |
| Inconsistência: o limite de reusable workflows. A documentação diz "50 únicos por arquivo de workflow". O changelog diz "50 no total por execução". | Não foi resolvida. |
| O Exa atingiu o limite de requisições uma vez. WebSearch foi usado só para localizar URLs, e o conteúdo foi verificado por leitura direta das páginas. | Sem efeito sobre as afirmações citadas. |
| A opção `directory` do Dependabot para composite actions em subpastas não foi verificada na referência de opções. | Não se afirma nada sobre isso. |
| A existência de `rapidsai/shared-actions` não foi verificada à parte. | Citada só como informação do README. |
| `lpsm-dev/.github` não foi encontrado de forma anônima. | Pode ser privado ou inexistente. |
| Do Well-Architected foram lidas duas páginas. | Outras páginas podem cobrir reuso de Actions. |
| Ferramentas de release, testes e prefixos de repositórios fora da amostra não foram avaliados. | A amostra tem 20 repositórios, não representa o ecossistema. |

## 8. Fontes

### 8.1 Documentação do GitHub

- [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [Reusing workflow configurations (referência)](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations)
- [Reusing workflow configurations (conceitos)](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations)
- [Create workflow templates](https://docs.github.com/en/actions/how-tos/reuse-automations/create-workflow-templates)
- [Share with your organization](https://docs.github.com/en/actions/how-tos/reuse-automations/share-with-your-organization)
- [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)
- [Manage custom actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/manage-custom-actions)
- [Release and maintain actions](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/release-and-maintain-actions)
- [Using immutable releases and tags to manage your actions' releases](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/using-immutable-releases-and-tags-to-manage-your-actions-releases)
- [Immutable releases](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases)
- [Publish in GitHub Marketplace](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/publish-in-github-marketplace)
- [Metadata syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/metadata-syntax)
- [About custom actions](https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions)
- [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [Workflow dependency lockfiles](https://docs.github.com/en/actions/concepts/security/workflow-dependency-lockfiles)
- [Control workflow execution](https://docs.github.com/en/actions/how-tos/administer/control-workflow-execution)
- [REST API: Actions permissions](https://docs.github.com/en/rest/actions/permissions)
- [Dependabot: ecossistemas suportados](https://docs.github.com/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories)
- [Creating a default community health file](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

### 8.2 GitHub Blog e Well-Architected

- [Changelog 2025-08-15: policy supports blocking and SHA pinning](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/)
- [Changelog 2025-10-28: immutable releases GA](https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/)
- [Changelog 2025-11-06: new releases for GitHub Actions](https://github.blog/changelog/2025-11-06-new-releases-for-github-actions-november-2025/)
- [Changelog 2026-10-14: workflow lockfiles in public preview](https://github.blog/changelog/2026-10-14-github-actions-workflow-lockfiles-in-public-preview/)
- [2026 security roadmap](https://github.blog/news-insights/product-news/whats-coming-to-our-github-actions-2026-security-roadmap/)
- [Well-Architected: scaling Actions reusability](https://wellarchitected.github.com/library/collaboration/recommendations/scaling-actions-reusability/)
- [Well-Architected: Actions security](https://wellarchitected.github.com/library/application-security/recommendations/actions-security/)

### 8.3 Repositórios da comunidade

Os 20 repositórios da seção 4, nos SHAs listados na tabela 4.1. Também foram consultados, como contexto oficial, `actions/checkout` (tag móvel `v7`, workflows `update-main-version.yml` e `publish-immutable-actions.yml`), `actions/toolkit` e `actions/typescript-action`.

### 8.4 Repositório avaliado

`lpsm-dev/reusable-workflows` no commit `4c3000c33970d51eba3d8493aa9e32e32e8b0dee`: `README.md`, `CONTRIBUTING.md`, `docs/adrs/0001` a `0004`, `.github/workflows/` e `.github/config/.releaserc.json`.
