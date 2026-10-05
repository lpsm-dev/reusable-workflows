---
status: accepted
date: 2026-10-04
---

# Documentação por componente e templates por ferramenta

Complementa o [0001](0001-layout.md). As três superfícies continuam as mesmas. A parte sobre `templates/` e o caminho `docs/workflows/<nome>.md` foram substituídos pelo [0003](0003-remove-templates.md).

## Contexto

O 0001 tirou a documentação de `.github/workflows/`, mas não definiu para onde ela vai. O README raiz misturava o detalhe do Gitleaks com a visão geral, e o Taskfile ainda gerava docs em `.github/workflows/docs/`, caminho que o 0001 proíbe.

Em `templates/`, os nomes não diziam o que cada arquivo era. `templates/.gitleaks.toml` tinha o nome da config de verdade, mas era o ruleset opcional do AzSK. `templates/.releaserc.json` publicava no GitLab sem indicar isso no nome. A config de semantic-release para GitHub só existia em `.github/config/`, que é a config interna deste repositório, e a documentação mandava copiar de lá.

## Decisão

- Cada reusable workflow público tem uma página escrita à mão em `docs/workflows/<nome>.md`. O README raiz só lista o workflow e aponta para essa página.
- Cada composite action tem um `actions/<nome>/README.md` gerado pelo action-docs (`task github:action:docs`), entre marcadores `action-docs-all`, com o caminho real da action no exemplo de uso.
- Templates ficam em `templates/<ferramenta>/<variante>.<extensão>`: `gitleaks/default.toml`, `gitleaks/azsk.toml`, `semantic-release/github.json` e `semantic-release/gitlab.json`.
- Quem consome copia só de `templates/`. `.github/config/` é a config interna deste repositório e pode mudar sem aviso.
- A documentação escrita à mão segue o padrão do gtoc, descrito no CONTRIBUTING.

## Opções consideradas

- **A (escolhida): docs em `docs/workflows/` e templates por ferramenta.** Uma página por workflow, e o nome de cada template diz a ferramenta e a variante.
- **B (rejeitada): manter tudo no README raiz.** Com mais workflows, o README vira o manual de cada um e a visão geral se perde.
- **C (rejeitada): gerar a página dos workflows inteira com action-docs.** O action-docs gera entradas e exemplo de uso. O que importa num workflow como o do Gitleaks (o que ele escaneia, o que fica de fora, as decisões de segurança) precisa ser escrito à mão.
- **D (rejeitada): renomear `templates/`.** O nome foi decidido no 0001 e não era o problema. O que confundia eram os nomes dos arquivos dentro da pasta.

## Consequências

- O README raiz vira a porta de entrada: estrutura, catálogo e exemplos curtos.
- Um workflow novo exige uma página em `docs/workflows/`, e uma action nova exige rodar `task github:action:docs`. O checklist está no CONTRIBUTING.
- `templates/semantic-release/github.json` nasce como cópia de `.github/config/.releaserc.json`. As duas podem divergir, porque uma é ponto de partida para outros projetos e a outra é a config deste repositório.
- O `gitleaks/azsk.toml` passou a usar `regexes` nas allowlists, que é a chave do Gitleaks 8, e ganhou o `id` que faltava na regra `CSCAN0240-2`. Antes disso, a config não carregava na versão 8.23.3 que o workflow instala.
