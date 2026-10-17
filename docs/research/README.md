# Pesquisa

Pesquisa junta fontes e o que foi lido. Não decide. A decisão, se houver, vai para `docs/adrs/`.

Formato:

- Nome: `research-nnn-titulo.md`. `nnn` tem três dígitos e começa em `001`. A ordem é a `date`, crescente. No mesmo dia, o título. Entrar, sair ou mudar a data recalcula a sequência desde `001` e atualiza os links.
- Corpo em PT-BR. Sem travessão.
- Cada afirmação de ferramenta ou API cita a fonte.
- Frontmatter na primeira linha: só `date` (`YYYY-MM-DD`). Sem `type`, `status`, `id`, `version`, `tags`, `related_docs` ou `review_date`.

## 1. Neste repo

- [research-001-github-reusable-pipelines-organization.md](research-001-github-reusable-pipelines-organization.md): práticas oficiais do GitHub e de 20 repositórios para organizar pipelines reutilizáveis. A decisão tirada dela está no [adr-005](../adrs/adr-005-adopt-community-practices.md).
