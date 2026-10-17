---
status: accepted
date: 2026-10-05
---

# Sem pasta templates: o padrão fica dentro do workflow

## 1. Contexto

### 1.1. Situação atual

`templates/` guardava arquivos para outros projetos copiarem. Nenhum era template de GitHub Actions, e nenhum se sustentava:

- `gitleaks/default.toml` só tinha `useDefault = true`, que dá o mesmo resultado que rodar o Gitleaks sem config. Ele existia porque o workflow exigia um arquivo.
- `gitleaks/azsk.toml` ficou de dezembro de 2024 a outubro de 2026 sem carregar no Gitleaks 8, porque nada o executava.
- `semantic-release/github.json` era cópia da config de release deste repositório, e nenhum workflow daqui usa semantic-release para outros projetos. `semantic-release/gitlab.json` era config de GitLab.

Os repositórios que chamam o workflow do Gitleaks escreveram as próprias configs, sem usar os templates.

A pasta também convivia com `.github/config/`, que guarda a config das ferramentas deste repositório. Eram duas pastas de config com públicos diferentes, e uma duplicava o conteúdo da outra.

### 1.2. Problema

Decidir se o repositório continua distribuindo arquivos para copiar, e onde fica o padrão de cada workflow.

### 1.3. Drivers

- **Modelo de consumo:** quem fixa um SHA recebe correções ao trocar o SHA, mas uma cópia nunca recebe.
- **Arquivo que quebra sem ninguém ver:** o AzSK passou quase dois anos sem carregar.

### 1.4. Constraints

- Os callers atuais passam `config` explícito e não podem quebrar.

## 2. Decisão

Decidimos remover `templates/` e pôr o padrão dentro do workflow, aceitando que o projeto que chama commite a própria config quando quiser personalizar.

- O repositório deixa de ter `templates/`. Ficam as duas superfícies que executam: reusable workflows e composite actions.
- O input `config` do workflow do Gitleaks passa a ser opcional. Sem ele, o workflow usa `.github/config/.gitleaks.toml` se o arquivo existir. Senão, vale a busca do próprio Gitleaks, que tenta `.gitleaks.toml` na raiz e depois as regras padrão. Com `config` informado, o arquivo precisa existir.
- Exemplos opcionais de config ficam na pasta do workflow, junto da página dele. O AzSK passa para `docs/workflows/gitleaks/azsk.toml`, e o CI deste repositório escaneia o código com esse arquivo.
- A página de cada workflow passa de `docs/workflows/<nome>.md` para `docs/workflows/<nome>/README.md`, no mesmo formato de `actions/<nome>/README.md`.
- Os templates de semantic-release saem. A config de release de cada projeto fica no próprio projeto.
- `.github/config/` continua com a config das ferramentas deste repositório. A `.gitleaks.toml` daqui sai, porque era igual às regras padrão.

## 3. Opções consideradas

### 3.1. Opção A: padrão dentro do workflow e exemplos na pasta do workflow

| Prós | Contras |
|---|---|
| O caller só commita config quando quer personalizar | O exemplo precisa de um teste para não quebrar |
| Uma pasta de config só | |

**Adotada**, porque mantém o modelo de consumo por SHA.

### 3.2. Opção B: manter `templates/`

| Prós | Contras |
|---|---|
| Nenhum link muda | Duas pastas de config, conteúdo duplicado e arquivos que quebram sem aviso |

**Rejeitada**, porque a cópia nunca recebe correção.

### 3.3. Opção C: renomear `templates/`, por exemplo para `configs/` ou `examples/`

| Prós | Contras |
|---|---|
| Nome mais claro | Mantém o modelo de cópia e uma pasta separada do workflow |

**Rejeitada**, porque muda só o nome.

### 3.4. Opção D: um template repository do GitHub com o kit comum a todo repositório novo

| Prós | Contras |
|---|---|
| Resolve o bootstrap de projetos novos | É outro problema, fora deste repositório |

**Adiada**, porque cabe num repositório próprio.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Sem arquivo para copiar | O caller escreve a própria config | O workflow funciona sem config, com as regras padrão |

## 5. Consequências

### 5.1. Positivas

- Os callers atuais continuam funcionando, porque passam `config` explícito e têm o arquivo.
- Um caller sem config passa a rodar com as regras padrão, em vez de falhar.
- O `_ci.yaml` escaneia com o AzSK. Se uma versão nova do Gitleaks invalidar o exemplo, o CI falha.
- Links para `templates/` em SHAs antigos continuam funcionando, porque o conteúdo de um commit não muda.

### 5.2. Negativas

- O próximo candidato a reuso é o `_release.yaml`, hoje copiado em outros repositórios.

## 6. Referências

- [adr-001-layout.md](adr-001-layout.md) e [adr-002-docs-and-templates.md](adr-002-docs-and-templates.md): esta decisão substitui a parte deles sobre `templates/`.
- [adr-006-docs-taxonomy.md](adr-006-docs-taxonomy.md): move a página do workflow para `docs/handbooks/<nome>/` e o AzSK para `.github/config/.gitleaks.toml`.
