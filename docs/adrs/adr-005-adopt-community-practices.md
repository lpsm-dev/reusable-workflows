---
status: accepted
date: 2026-10-17
---

# Práticas oficiais e da comunidade adotadas depois da pesquisa

Complementa o [001](adr-001-layout.md) e o [003](adr-003-release-without-commits.md). O layout do 001 continua valendo.

## 1. Contexto

A pesquisa [Organização de repositórios com pipelines reutilizáveis](../research/research-001-github-reusable-pipelines-organization.md) comparou este repositório com a documentação do GitHub e com 20 repositórios públicos. A seção 6.2 da pesquisa lista onde este repositório diverge. Os pontos principais:

- Os pins por SHA não tinham atualização automática. Os 20 repositórios usam Dependabot ou Renovate.
- O `_release.yaml` instalava o semantic-release sem lockfile, com o Node em `lts/*`.
- O nível superior dos workflows dava `contents: read` a todo job. O GitHub Well-Architected recomenda `permissions: {}` no topo e permissões por job.
- Nenhum lint verificava as composite actions. O zizmor audita workflows e actions.
- Não havia CODEOWNERS nem SECURITY.md.
- As tags não tinham o prefixo `v`, que 12 de 16 repositórios com tags usam por padrão.
- O devbox declarava versões de gitleaks e actionlint diferentes das que o CI instala.

## 2. Decisão

- **Dependabot.** `.github/dependabot.yml` cobre o ecossistema `github-actions` em `/` e `/actions/*` e o ecossistema `npm` em `.github/config/release`. Roda toda semana, com um pull request agrupado por ecossistema e cooldown de 7 dias antes de propor uma versão nova, como pede o zizmor.
- **Release com lockfile.** O semantic-release e os plugins ficam em `.github/config/release/`, com `package.json`, `package-lock.json` e `.releaserc.json`. O job roda `npm ci` nessa pasta e executa o binário a partir dela, porque o semantic-release resolve os plugins pelo diretório de trabalho. O Node fica fixo na LTS 24.22.0.
- **Permissões.** Todo workflow declara `permissions: {}` no topo, e cada job declara o que usa.
- **zizmor.** O job `Zizmor` de `_check-workflows.yaml` audita `.github/workflows/` e `actions/` em modo offline. O binário tem versão e SHA256 fixados, como o actionlint.
- **CODEOWNERS e SECURITY.md.** O CODEOWNERS dá todos os caminhos ao mantenedor. O ruleset continua sem exigir revisão, como diz o 003. O SECURITY.md aponta para o reporte privado de vulnerabilidade do GitHub.
- **Tag `vX.Y.Z`, sem major móvel.** O `tagFormat` passa a `v${version}`. A tag `v1.0.0` é criada no commit da `1.0.0`, que continua existindo, para o semantic-release achar a última versão. Não há `v1` móvel, porque o consumo é por SHA e uma tag móvel não convive com releases imutáveis.
- **Devbox alinhado ao CI.** O gitleaks vai para 8.23.3 e o actionlint para 1.7.12. O zizmor entra na 1.30.1, a mais nova do registry do devbox. O CI roda a 1.31.1.

## 3. Opções consideradas e rejeitadas

| Opção | Motivo |
|---|---|
| Um repositório por action, para publicar no Marketplace | O Marketplace exige uma action por repositório, com o metadado na raiz. O 001 escolheu um SHA único como controle da cadeia, e publicar no Marketplace não é objetivo. |
| Repositório `lpsm-dev/.github` com `workflow-templates/` | Workflow templates são recurso de organização, e `lpsm-dev` é conta pessoal. O 004 já removeu as cópias. |
| Repositório `lpsm-dev/.github` só para community health | Funciona em conta pessoal, mas o SECURITY.md e o CODEOWNERS bastam aqui. Não há outro repositório pedindo esses padrões agora. |
| Tag móvel `v1` | Ver a decisão sobre tags. |
| LICENSE | Decisão do mantenedor: o repositório continua sem licença. Consequência: o código é público para leitura, sem permissão formal de reuso por terceiros. |
| Referência `$/` no lugar de `./.github/workflows/` | Pouco ganho com um único workflow, e o GHES não suporta a sintaxe. |

## 4. Consequências

- O próximo release depende da tag `v1.0.0` existir. Sem ela, o semantic-release recomeça na 1.0.0.
- O título do pull request vira a mensagem do squash e decide o tipo da versão.
- Ficam como passos manuais nas configurações do repositório:
  - ligar releases imutáveis;
  - ligar `sha_pinning_required`;
  - ligar o reporte privado de vulnerabilidade;
  - tornar o check `Zizmor` obrigatório no ruleset.
  O README lista os que ainda faltam em Pendências conhecidas.
- As composite actions continuam sem teste automatizado, porque exercitá-las exige uma conta AWS e uma role OIDC.
