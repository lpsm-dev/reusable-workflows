---
status: accepted
date: 2026-10-17
---

# docs/ organizado por tipo de documento, nas regras dos dotfiles

## 1. Contexto

### 1.1. Situação atual

O `docs/` tinha três pastas com critérios diferentes:
- `adrs/` (`NNNN-titulo.md`);
- `research/` (nome livre);
- `workflows/<nome>/` (página do workflow e exemplos de config).

O local da página do workflow veio do [adr-002](adr-002-docs-and-templates.md) e do [adr-004](adr-004-remove-templates.md).

Os dotfiles do mantenedor já organizam o `docs/` por tipo de documento: uma pasta por tipo, nome `tipo-nnn-titulo.md`, README por pasta e esqueletos em `_templates/`. Este repositório não seguia essa regra.

### 1.2. Problema

Definir onde cada documento deste repositório mora, com a mesma regra dos dotfiles, sem quebrar o CI nem os links.

### 1.3. Drivers

- **Uma regra para os repositórios do mantenedor:** quem já conhece o `docs/` dos dotfiles acha o documento aqui sem ler outra convenção.
- **Pasta é tipo:** `workflows/` é um assunto, não um tipo de documento.

### 1.4. Constraints

- Os ADRs aceitos não mudam de decisão. Só nome de arquivo, numeração das seções e links.
- O CI chama o Gitleaks com o exemplo `azsk.toml`, então o caminho do exemplo muda junto no `_ci.yaml`.

## 2. Decisão

Decidimos organizar o `docs/` como nos dotfiles, aceitando renomear os ADRs e mover a página do workflow.

| Antes | Depois |
|---|---|
| `adrs/0001-layout.md` | `adrs/adr-001-layout.md` |
| `adrs/0002-docs-and-templates.md` | `adrs/adr-002-docs-and-templates.md` |
| `adrs/0004-release-without-commits.md` | `adrs/adr-003-release-without-commits.md` |
| `adrs/0003-remove-templates.md` | `adrs/adr-004-remove-templates.md` |
| `adrs/0005-adopt-community-practices.md` | `adrs/adr-005-adopt-community-practices.md` |
| `research/github-reusable-pipelines-organization.md` | `research/research-001-github-reusable-pipelines-organization.md` |
| `workflows/gitleaks/README.md` | `handbooks/gitleaks/handbook-001-gitleaks-workflow.md` |
| `workflows/gitleaks/azsk.toml` | `handbooks/gitleaks/azsk.toml` |

Os antigos 0003 e 0004 trocam de número. Os dois têm `date: 2026-10-05`, e a regra desempata pelo título: "Release sem commit..." vem antes de "Sem pasta templates...".

Entram `docs/README.md`, um README por pasta, `_assets/`, `_inbox/`, `_templates/`, `rfcs/` e `runbooks/`. O README de cada composite action continua em `actions/<nome>/`, ao lado do `action.yaml`, porque é gerado a partir dele.

Esta decisão substitui o local da página do workflow definido no adr-002 e no adr-004. O resto dos dois continua valendo.

## 3. Opções consideradas

### 3.1. Opção A: tipos dos dotfiles, página do workflow como handbook

A página explica o workflow, como as peças se relacionam e para onde seguir. Isso é um handbook. O exemplo de config fica na pasta do assunto.

**Adotada**, porque segue a regra sem abrir pasta fora dos tipos.

### 3.2. Opção B: tipos dos dotfiles, mantendo `docs/workflows/`

Menos arquivos movidos e o caminho do `azsk.toml` não muda.

**Rejeitada**, porque `workflows/` não é um tipo. A regra lista "reference" e "guide" entre os nomes que não viram pasta.

### 3.3. Opção C: página ao lado do workflow, em `.github/workflows/`

Espelha `actions/<nome>/README.md`, como faz o grafana (pesquisa 001).

**Rejeitada**, porque mistura Markdown com os arquivos que o GitHub executa, e o ADR 001 tirou a documentação dessa pasta.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Os números 003 e 004 trocam | Uma referência antiga a "ADR 0003" ou "ADR 0004" aponta para outro documento | A tabela da seção 2 registra a troca |
| O caminho do `azsk.toml` muda | O comando `curl` do handbook usa um SHA. Um SHA antigo continua com o caminho antigo | Quem baixa num SHA novo usa o caminho novo, que já está no handbook |

## 5. Consequências

### 5.1. Positivas

- O `docs/` deste repositório e o dos dotfiles têm a mesma regra.
- Cada tipo tem um esqueleto em `_templates/`.

### 5.2. Negativas

- Um workflow novo exige um handbook novo e recalcula a numeração quando a data dele cai antes de outro handbook.

## 6. Referências

- [adr-002-docs-and-templates.md](adr-002-docs-and-templates.md) e [adr-004-remove-templates.md](adr-004-remove-templates.md): local anterior da página do workflow.
- [docs/README.md](../README.md): as regras de nome e de tipo.
- [research-001-github-reusable-pipelines-organization.md](../research/research-001-github-reusable-pipelines-organization.md): como outros repositórios documentam workflows.
