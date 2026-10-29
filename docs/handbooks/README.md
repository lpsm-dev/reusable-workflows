# handbooks

O handbook explica um assunto: o que é, como as peças se relacionam, e para onde seguir.

O handbook é o arquivo `handbook-nnn-titulo.md`. A pasta do assunto guarda o resto, como imagens. Config de ferramenta não entra em `docs/`: fica em `.github/config/`. `nnn` tem três dígitos e começa em `001`. A ordem é a `date`, crescente. No mesmo dia, o título. Entrar, sair ou mudar a data recalcula a sequência desde `001` e atualiza os links.

Frontmatter na primeira linha: só `date` (`YYYY-MM-DD`). Sem `type`, `status`, `id`, `version`, `tags`, `related_docs` ou `review_date`.

Cada reusable workflow público tem um handbook, na pasta com o nome do workflow.

## 1. Neste repo

| Assunto | Handbook | Resto da pasta |
|---|---|---|
| `gitleaks` | [handbook-001-gitleaks-workflow.md](gitleaks/handbook-001-gitleaks-workflow.md) | Nada. A config do AzSK fica em `.github/config/.gitleaks.toml` |
| `semantic-release` | [handbook-002-semantic-release-workflow.md](semantic-release/handbook-002-semantic-release-workflow.md) | A configuração e o lockfile ficam no repositório que chama |
