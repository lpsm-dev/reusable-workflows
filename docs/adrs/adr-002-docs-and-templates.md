---
status: accepted
date: 2026-10-04
---

# Documentação por componente e templates por ferramenta

## 1. Contexto

### 1.1. Situação atual

O [adr-001](adr-001-layout.md) tirou a documentação de `.github/workflows/`, mas não definiu para onde ela vai. O README raiz misturava o detalhe do Gitleaks com a visão geral. O Taskfile ainda gerava docs em `.github/workflows/docs/`, caminho que o adr-001 proíbe.

Em `templates/`, os nomes não diziam o que cada arquivo era:
- `templates/.gitleaks.toml` tinha o nome da config de verdade, mas era o ruleset opcional do AzSK.
- `templates/.releaserc.json` publicava no GitLab sem indicar isso no nome.
- A config de semantic-release para GitHub só existia em `.github/config/`, a config interna deste repositório, e a documentação mandava copiar de lá.

### 1.2. Problema

Definir onde fica a documentação de cada workflow e de cada action, e como nomear os templates para que o nome diga o que o arquivo é.

### 1.3. Drivers

- **README legível:** com mais workflows, o README raiz vira o manual de cada um e a visão geral se perde.
- **Documentação que não mente:** o que importa num workflow (o que ele escaneia, o que fica de fora, as decisões de segurança) precisa ser escrito à mão.

### 1.4. Constraints

- As três superfícies do adr-001 não mudam.

## 2. Decisão

Decidimos documentar cada componente na própria página e nomear os templates por ferramenta e variante, aceitando manter uma página escrita à mão por workflow.

- Cada reusable workflow público tem uma página escrita à mão em `docs/workflows/<nome>.md`. O README raiz só lista o workflow e aponta para essa página.
- Cada composite action tem um `actions/<nome>/README.md` gerado pelo action-docs (`task github:action:docs`), entre marcadores `action-docs-all`, com o caminho real da action no exemplo de uso.
- Templates ficam em `templates/<ferramenta>/<variante>.<extensão>`: `gitleaks/default.toml`, `gitleaks/azsk.toml`, `semantic-release/github.json` e `semantic-release/gitlab.json`.
- Quem consome copia só de `templates/`. `.github/config/` é a config interna deste repositório e pode mudar sem aviso.
- A documentação escrita à mão segue o padrão do gtoc, descrito no CONTRIBUTING.

## 3. Opções consideradas

### 3.1. Opção A: docs em `docs/workflows/` e templates por ferramenta

Uma página por workflow, e o nome de cada template diz a ferramenta e a variante.

| Prós | Contras |
|---|---|
| README raiz curto | Uma página a mais para manter por workflow |
| Nome do template diz o que ele é | |

**Adotada**, porque separa visão geral de detalhe.

### 3.2. Opção B: manter tudo no README raiz

| Prós | Contras |
|---|---|
| Um arquivo só | A visão geral se perde com mais workflows |

**Rejeitada**, porque não escala.

### 3.3. Opção C: gerar a página dos workflows inteira com action-docs

| Prós | Contras |
|---|---|
| Página sempre igual ao YAML | Gera só entradas e exemplo; o que importa precisa ser escrito à mão |

**Rejeitada**, porque a parte que importa não vem do YAML.

### 3.4. Opção D: renomear `templates/`

| Prós | Contras |
|---|---|
| Nome novo para a pasta | O nome da pasta não era o problema |

**Rejeitada**, porque o que confundia eram os nomes dos arquivos dentro da pasta.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Página escrita à mão | Pode divergir do YAML | Checklist no CONTRIBUTING para todo workflow novo |
| Template copiado da config interna | As duas podem divergir | Uma é ponto de partida para outros projetos; a outra é a config deste repositório |

## 5. Consequências

### 5.1. Positivas

- O README raiz vira a porta de entrada: estrutura, catálogo e exemplos curtos.
- O `gitleaks/azsk.toml` passou a usar `regexes` nas allowlists, que é a chave do Gitleaks 8, e ganhou o `id` que faltava na regra `CSCAN0240-2`. Antes disso, a config não carregava na versão 8.23.3 que o workflow instala.

### 5.2. Negativas

- Um workflow novo exige uma página, e uma action nova exige rodar `task github:action:docs`.
- `templates/semantic-release/github.json` nasce como cópia de `.github/config/.releaserc.json`.

## 6. Referências

- [adr-001-layout.md](adr-001-layout.md): as três superfícies.
- [adr-004-remove-templates.md](adr-004-remove-templates.md): remove `templates/` e muda a página para `docs/workflows/<nome>/README.md`.
- [adr-006-docs-taxonomy.md](adr-006-docs-taxonomy.md): move a página do workflow para `docs/handbooks/<nome>/`.
