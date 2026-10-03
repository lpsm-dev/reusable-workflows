---
status: accepted
date: 2026-10-03
---

# Layout: workflows soltos, composite actions e templates inertes

O GitHub não suporta subdiretórios de `.github/workflows/`. A documentação de [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) coloca o arquivo do workflow nessa pasta e descarta subdiretórios. Por isso o workflow chamável `gitleaks.yaml` permanece em `.github/workflows/gitleaks.yaml`. O caminho público não muda.

O repositório continua único. Um SHA só, no monorepo, é o controle da cadeia de dependência (OWASP CI/CD, CICD-SEC-3 e CICD-SEC-4). Vários repositórios seriam várias tags móveis para vigiar. O abstract de [On the GitHub Actions Language (arXiv:2605.26825, 2026)](https://arxiv.org/abs/2605.26825) liga a complexidade da linguagem do workflow a falha de execução. O relatório do AlphaXiv para esse id ainda não existe (404). A leitura usada é o abstract mais a regra do GitHub, não um desenho de pastas tirado do paper.

Três superfícies, e só as duas primeiras executam:

- **Workflow.** Arquivo solto em `.github/workflows/`. O chamável não tem `_` no nome e declara `workflow_call`. Hoje: `gitleaks.yaml`. O workflow interno deste repositório usa prefixo `_`, como `_release.yaml` e `_check-workflows.yaml`. O CI interno é `.github/workflows/_ci.yaml` e continua chamando `./.github/workflows/gitleaks.yaml`. Nada de fora usa esse arquivo.
- **Composite action.** `actions/<nome>/action.yaml`, um diretório por action. As três que existem ficam: `aws-cloudfront-deploy`, `aws-ecr-create`, `aws-eks-deploy`. O catálogo lista só esses diretórios, com o caminho real de cada `action.yaml`.
- **Template.** `templates/` é cópia única e não é alvo de `uses:`. O scan de verdade continua em `.github/config/.gitleaks.toml` (só `[extend] useDefault = true`). O TOML em `templates/.gitleaks.toml` não é a config do CI.

## Considered Options

- **A (escolhida) - três superfícies num repositório só.** Workflow chamável solto, sem underscore, com `workflow_call`. Workflow interno com `_`. Composite action só nos três diretórios que o git tem. `templates/` fica fora de `uses:`.
- **B (rejeitada) - subpastas em `.github/workflows/`.** O GitHub não suporta subdiretórios dessa pasta. Um `uses:` apontando para arquivo dentro de subpasta não resolve.
- **C (rejeitada) - um repositório por action.** Cada repositório vira uma tag móvel a mais para vigiar. O SHA único do monorepo deixa de ser o controle da cadeia.
- **D (rejeitada) - recolocar no catálogo as actions de npm que o README antigo citava.** Esses diretórios não estão no git. O catálogo passa a listar só o que existe.

## Consequences

- `gitleaks.yaml` permanece em `.github/workflows/gitleaks.yaml`. Callers pinados continuam nesse caminho.
- O CI interno deste repositório é `.github/workflows/_ci.yaml` e chama `./.github/workflows/gitleaks.yaml`.
- `actions/README.md` lista só `aws-cloudfront-deploy`, `aws-ecr-create` e `aws-eks-deploy`, cada uma com o caminho real do `action.yaml`.
- Documentação não fica em `.github/workflows/`. Markdown vazio dessa árvore sai do git.
- **Gatilho de revisão:** se o GitHub passar a suportar subdiretórios de `.github/workflows/`, ou se uma quarta composite action entrar no git.
