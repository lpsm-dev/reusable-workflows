---
status: accepted
date: 2026-10-03
---

# Layout: workflows soltos, composite actions e templates inertes

## 1. Contexto

### 1.1. Situação atual

O repositório guarda reusable workflows e composite actions que outros projetos chamam. O workflow chamável `gitleaks.yaml` fica em `.github/workflows/`. As composite actions `aws-cloudfront-deploy`, `aws-ecr-create` e `aws-eks-deploy` têm um diretório cada. A pasta `templates/` guarda arquivos para copiar.

O README antigo citava actions de npm que não estão no git.

### 1.2. Problema

Definir onde cada tipo de peça mora e como separar o que outros repositórios chamam do que só este repositório usa.

### 1.3. Drivers

- **Regra do GitHub:** a documentação de [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows) põe o reusable workflow direto em `.github/workflows/` e não suporta subdiretórios.
- **Cadeia de dependência (OWASP CI/CD, CICD-SEC-3 e CICD-SEC-4):** um SHA só, num monorepo, controla tudo que o caller recebe. Vários repositórios seriam várias referências móveis para vigiar.
- **Complexidade:** o abstract de [On the GitHub Actions Language (arXiv:2605.26825, 2026)](https://arxiv.org/abs/2605.26825) liga a complexidade da linguagem do workflow a falha de execução. A leitura usada é o abstract mais a regra do GitHub, não um desenho de pastas tirado do paper.

### 1.4. Constraints

- O caminho público `.github/workflows/gitleaks.yaml` não muda, porque callers já fixaram esse caminho.

## 2. Decisão

Decidimos ter três superfícies num repositório só, e só as duas primeiras executam, aceitando que workflows públicos e internos dividam a mesma pasta.

- **Workflow.** Arquivo solto em `.github/workflows/`. O chamável não tem `_` no nome e declara `workflow_call`, como `gitleaks.yaml`. O workflow interno usa prefixo `_`, como `_ci.yaml`, `_release.yaml` e `_check-workflows.yaml`. O `_ci.yaml` chama `./.github/workflows/gitleaks.yaml`, e nada de fora usa os arquivos com `_`.
- **Composite action.** `actions/<nome>/action.yaml`, um diretório por action. O catálogo lista só os diretórios que existem, com o caminho real de cada `action.yaml`.
- **Template.** `templates/` é cópia única e não é alvo de `uses:`. A config do CI continua em `.github/config/.gitleaks.toml`.

## 3. Opções consideradas

### 3.1. Opção A: três superfícies num repositório só

Workflow chamável solto, sem `_`, com `workflow_call`. Workflow interno com `_`. Composite action só nos diretórios que o git tem. `templates/` fica fora de `uses:`.

| Prós | Contras |
|---|---|
| Um SHA controla tudo que o caller recebe | Workflows públicos e internos na mesma pasta |
| Segue a regra do GitHub sem contorno | A separação depende de uma convenção de nome |

**Adotada**, porque é o único desenho que respeita a regra do GitHub e mantém um SHA só.

### 3.2. Opção B: subpastas em `.github/workflows/`

Separar públicos e internos em subpastas.

| Prós | Contras |
|---|---|
| Separação visível na árvore | O GitHub não resolve `uses:` para arquivo em subpasta |

**Rejeitada**, porque o GitHub não suporta subdiretórios dessa pasta.

### 3.3. Opção C: um repositório por action

Cada composite action no próprio repositório.

| Prós | Contras |
|---|---|
| Versão independente por action | Cada repositório vira uma referência móvel a mais para vigiar |
| Publicável no Marketplace | O SHA único deixa de ser o controle da cadeia |

**Rejeitada**, porque perde o controle da cadeia por um SHA só.

### 3.4. Opção D: recolocar no catálogo as actions de npm do README antigo

Manter as entradas do README antigo.

| Prós | Contras |
|---|---|
| Nenhum link some | Os diretórios não estão no git, então o catálogo mente |

**Rejeitada**, porque o catálogo passa a listar só o que existe.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
|---|---|---|
| Públicos e internos na mesma pasta | Um caller pode chamar um workflow interno por engano | Prefixo `_` nos internos e nenhum `workflow_call` neles |
| Versão única para tudo | Uma mudança numa action gera versão nova para todas as peças | O caller fixa SHA e escolhe quando trocar |

## 5. Consequências

### 5.1. Positivas

- `gitleaks.yaml` permanece em `.github/workflows/gitleaks.yaml`, e os callers fixados continuam funcionando.
- `actions/README.md` lista só as actions que existem, cada uma com o caminho real do `action.yaml`.
- A documentação não fica em `.github/workflows/`. Markdown vazio dessa árvore sai do git.

### 5.2. Negativas

- A convenção de prefixo precisa ser seguida à mão.
- **Gatilho de revisão:** o GitHub passar a suportar subdiretórios de `.github/workflows/`, ou uma quarta composite action entrar no git.

## 6. Referências

- [adr-002-docs-and-templates.md](adr-002-docs-and-templates.md): complementa esta decisão com o local da documentação.
- [adr-004-remove-templates.md](adr-004-remove-templates.md): substitui a parte sobre `templates/`.
- [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).
- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks).
