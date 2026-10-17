# RFCs

Uma RFC é uma proposta antes da decisão. Ainda não é ADR.

Formato:

- Nome: `rfc-nnn-titulo.md`. `nnn` tem três dígitos e começa em `001`. A ordem é a `date`, crescente. No mesmo dia, o título. Entrar, sair ou mudar a data recalcula a sequência desde `001` e atualiza os links.
- Frontmatter na primeira linha: `status` (`proposed`, `accepted`, `rejected`) e `date` (`YYYY-MM-DD`). Sem `type`, `id`, `version`, `tags`, `related_docs` ou `review_date`.
- Corpo em PT-BR. Sem travessão.
- Se a proposta for aceita, o ADR correspondente nasce em `docs/adrs/` e esta RFC ganha o link. A RFC não é reescrita como se fosse a decisão.

Não há RFC aberta neste repo.
