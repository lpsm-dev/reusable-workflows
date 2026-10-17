---
status: accepted
date: 2026-10-17
---

# docs/ organizado por tipo de documento e config em .github/config

## 1. Contexto

### 1.1. Situação atual

O `docs/` tinha três pastas com critérios diferentes:
- `adrs/`, com nomes `NNNN-titulo.md`;
- `research/`, com nome livre;
- `workflows/<nome>/`, com a página do workflow e exemplos de config.

O local da página do workflow veio do [adr-002](adr-002-docs-and-templates.md) e do [adr-004](adr-004-remove-templates.md). O CI escaneava o código com `docs/workflows/gitleaks/azsk.toml`, então um arquivo de config real morava dentro de `docs/`.

### 1.2. Problema

Definir onde cada documento mora, com uma regra única para todos os tipos, e tirar de `docs/` o que não é documento.

### 1.3. Drivers

- **Pasta é tipo:** quem procura uma decisão, uma pesquisa ou uma explicação acha pelo tipo. `workflows/` é um assunto, não um tipo de documento.
- **Config junto da config:** `.github/config/` guarda a configuração das ferramentas deste repositório. Um arquivo que o CI carrega é config, não exemplo.
- **Estrutura previsível:** cada tipo tem um esqueleto em `docs/_templates/`.

### 1.4. Constraints

- Os ADRs aceitos não mudam de decisão. Mudam o nome do arquivo, a estrutura das seções e os links.
- O CI precisa continuar validando o ruleset do AzSK a cada pull request.

## 2. Decisão

Decidimos organizar o `docs/` por tipo de documento e mover o AzSK para `.github/config/.gitleaks.toml`, aceitando renomear os ADRs e mudar o caminho do exemplo.

| Antes | Depois |
|---|---|
| `adrs/0001-layout.md` | `adrs/adr-001-layout.md` |
| `adrs/0002-docs-and-templates.md` | `adrs/adr-002-docs-and-templates.md` |
| `adrs/0004-release-without-commits.md` | `adrs/adr-003-release-without-commits.md` |
| `adrs/0003-remove-templates.md` | `adrs/adr-004-remove-templates.md` |
| `adrs/0005-adopt-community-practices.md` | `adrs/adr-005-adopt-community-practices.md` |
| `research/github-reusable-pipelines-organization.md` | `research/research-001-github-reusable-pipelines-organization.md` |
| `workflows/gitleaks/README.md` | `handbooks/gitleaks/handbook-001-gitleaks-workflow.md` |
| `workflows/gitleaks/azsk.toml` | `.github/config/.gitleaks.toml` (fora de `docs/`) |

- A regra de nome é `tipo-nnn-titulo.md`, numerada pela `date`. No mesmo dia, desempata o título. Os antigos 0003 e 0004 trocam de número: os dois têm `date: 2026-10-05`, e "Release sem commit..." vem antes de "Sem pasta templates...".
- Entram `docs/README.md`, um README por pasta, `_assets/`, `_inbox/`, `_templates/`, `rfcs/` e `runbooks/`. Todo documento segue o esqueleto do tipo.
- O AzSK vira a config do Gitleaks deste repositório. O `_ci.yaml` deixa de passar `config:`, e o workflow acha o arquivo pela busca padrão. O CI passa a exercitar também essa busca.
- O README de cada composite action continua em `actions/<nome>/`, ao lado do `action.yaml`, porque é gerado a partir dele.

Esta decisão substitui o local da página do workflow e do exemplo de config definido no adr-002 e no adr-004. O resto dos dois continua valendo.

## 3. Opções consideradas

### 3.1. Opção A: tipos de documento e config em `.github/config/`

A página do workflow explica o que ele é, como as peças se ligam e para onde seguir. Isso é um handbook.

| Prós | Contras |
|---|---|
| Uma regra para todo o `docs/` | Muitos arquivos renomeados |
| Nenhuma config real dentro de `docs/` | O caminho do exemplo muda para quem baixa |

**Adotada**, porque segue a regra sem abrir pasta fora dos tipos.

### 3.2. Opção B: tipos de documento, mantendo `docs/workflows/`

| Prós | Contras |
|---|---|
| Menos arquivos movidos | `workflows/` não é tipo de documento |
| | A config do CI continua dentro de `docs/` |

**Rejeitada**, porque mantém as duas exceções.

### 3.3. Opção C: página ao lado do workflow, em `.github/workflows/`

Espelha `actions/<nome>/README.md`, como faz o grafana (research-001).

| Prós | Contras |
|---|---|
| Página perto do YAML | Mistura Markdown com os arquivos que o GitHub executa |

**Rejeitada**, porque o adr-001 tirou a documentação dessa pasta.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Os números 003 e 004 trocam | Uma referência antiga a "ADR 0003" ou "ADR 0004" aponta para outro documento | A tabela da seção 2 registra a troca |
| O caminho do AzSK muda | Um SHA antigo continua com o caminho antigo | O handbook usa o caminho novo, válido para SHAs novos |

## 5. Consequências

### 5.1. Positivas

- Cada tipo de documento tem uma pasta, um README e um esqueleto.
- `.github/config/` volta a ser o único lugar de config deste repositório.

### 5.2. Negativas

- Um workflow novo exige um handbook novo. A numeração é recalculada quando a data dele cai antes de outro handbook.

## 6. Referências

- [adr-002-docs-and-templates.md](adr-002-docs-and-templates.md) e [adr-004-remove-templates.md](adr-004-remove-templates.md): local anterior da página e do exemplo.
- [docs/README.md](../README.md): as regras de nome e de tipo.
- [research-001-github-reusable-pipelines-organization.md](../research/research-001-github-reusable-pipelines-organization.md): como outros repositórios documentam workflows.
