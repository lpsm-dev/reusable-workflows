# ADRs

Um ADR registra uma decisão, o contexto, as alternativas e as consequências. Não é um diário e não é uma pesquisa.

Formato:

- Frontmatter na primeira linha: `status` (`proposed`, `accepted`, `rejected`, `superseded`) e `date` (`YYYY-MM-DD`). Opcional, só na sucessão: `supersedes` e `superseded_by`, com o nome do arquivo. Sem `type`, `id`, `version`, `tags`, `related_docs` ou `review_date`. O esqueleto está em [`../_templates/adr.md`](../_templates/adr.md).
- Nome: `adr-nnn-titulo.md`. `nnn` tem três dígitos e começa em `001`. A ordem é a `date`, crescente. No mesmo dia, o título. Entrar, sair ou mudar a data recalcula a sequência desde `001` e atualiza os links.
- Corpo em PT-BR, com seções numeradas. Sem travessão.
- Não editar decisão aceita. Mudança de rumo vira um ADR novo que referencia o anterior.

Pesquisa fica em `docs/research/`. Proposta ainda sem decisão fica em `docs/rfcs/`.

## 1. Neste repo

| ADR | Decisão | Status |
|---|---|---|
| [adr-001-layout.md](adr-001-layout.md) | Workflows soltos em `.github/workflows/`, composite actions em `actions/` | accepted, parte de `templates/` substituída pelo 004 |
| [adr-002-docs-and-templates.md](adr-002-docs-and-templates.md) | Documentação por componente | accepted, parte de `templates/` substituída pelo 004 e local da página pelo 006 |
| [adr-003-release-without-commits.md](adr-003-release-without-commits.md) | Release sem commit na `main` e ruleset na `main` | accepted |
| [adr-004-remove-templates.md](adr-004-remove-templates.md) | Sem pasta `templates/`, o padrão fica dentro do workflow | accepted, local da página substituído pelo 006 |
| [adr-005-adopt-community-practices.md](adr-005-adopt-community-practices.md) | Práticas adotadas depois da pesquisa 001 | accepted |
| [adr-006-docs-taxonomy.md](adr-006-docs-taxonomy.md) | `docs/` organizado por tipo de documento | accepted |
