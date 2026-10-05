---
status: accepted
date: 2026-10-05
---

# Sem pasta templates: o padrão fica dentro do workflow

Substitui a parte sobre `templates/` do [0001](0001-layout.md) e do [0002](0002-docs-and-templates.md). O resto dos dois continua valendo.

## Contexto

`templates/` guardava arquivos para outros projetos copiarem. Nenhum era template de GitHub Actions, e nenhum se sustentava:

- `gitleaks/default.toml` só tinha `useDefault = true`, que dá o mesmo resultado que rodar o Gitleaks sem config. Ele existia porque o workflow exigia um arquivo.
- `gitleaks/azsk.toml` ficou de dezembro de 2024 a outubro de 2026 sem carregar no Gitleaks 8, porque nada o executava.
- `semantic-release/github.json` era cópia da config de release deste repositório, e nenhum workflow daqui usa semantic-release para outros projetos. `semantic-release/gitlab.json` era config de GitLab.

Os dois repositórios que chamam o workflow do Gitleaks, `dotfiles` e `dotfiles-private`, escreveram as próprias configs, sem usar os templates. Além disso, a cópia sai do modelo deste repositório: quem fixa um SHA recebe correções ao trocar o SHA, mas uma cópia nunca recebe.

A pasta também convivia com `.github/config/`, que guarda a config das ferramentas deste repositório. Eram duas pastas de config com públicos diferentes, e uma duplicava o conteúdo da outra.

## Decisão

- O repositório deixa de ter `templates/`. Ficam as duas superfícies que executam: reusable workflows e composite actions.
- O input `config` do workflow do Gitleaks passa a ser opcional. Sem ele, o workflow usa `.github/config/.gitleaks.toml` se o arquivo existir; senão, vale a busca do próprio Gitleaks, que tenta `.gitleaks.toml` na raiz e depois as regras padrão. Com `config` informado, o arquivo precisa existir.
- Exemplos opcionais de config ficam na pasta do workflow, junto da página dele. O AzSK passa para `docs/workflows/gitleaks/azsk.toml`, e o CI deste repositório escaneia o código com esse arquivo, para garantir que ele carrega na versão do Gitleaks que o workflow instala.
- A página de cada workflow passa de `docs/workflows/<nome>.md` para `docs/workflows/<nome>/README.md`, no mesmo formato de `actions/<nome>/README.md`.
- Os templates de semantic-release saem. A config de release de cada projeto fica no próprio projeto.
- `.github/config/` continua com a config das ferramentas deste repositório (semantic-release e yamllint). A `.gitleaks.toml` daqui sai, porque era igual às regras padrão.

## Opções consideradas

- **A (escolhida): padrão dentro do workflow e exemplos na pasta do workflow.** O projeto que chama só commita config quando quer personalizar.
- **B (rejeitada): manter `templates/`.** Duas pastas de config com públicos diferentes, conteúdo duplicado e arquivos que quebram sem ninguém perceber.
- **C (rejeitada): renomear `templates/`, por exemplo para `configs/` ou `examples/`.** Muda o nome, mas mantém o modelo de cópia e uma pasta separada do workflow a que cada arquivo pertence.
- **D (adiada): um template repository do GitHub com o kit comum a todo repositório novo (Devbox, Taskfile, pre-commit, release).** É outro problema e cabe num repositório próprio, não neste.

## Consequências

- Os callers atuais continuam funcionando: `dotfiles` e `dotfiles-private` passam `config` explícito e têm o arquivo.
- Um caller sem config passa a rodar com as regras padrão, em vez de falhar.
- O `_ci.yaml` passa `config: docs/workflows/gitleaks/azsk.toml`. Se uma versão nova do Gitleaks invalidar o exemplo, o CI falha.
- Links para `templates/` em SHAs antigos continuam funcionando, porque o conteúdo de um commit não muda.
- O próximo candidato a reuso é o `_release.yaml`, hoje copiado em seis repositórios.
