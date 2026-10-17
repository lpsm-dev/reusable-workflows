# AGENTS.md

Instruções para agentes de código neste repositório. Este arquivo diz o que fazer e aponta para onde cada regra mora. Ele não repete as regras. Quando uma regra mudar, mude o documento canônico, não este arquivo.

## 1. O que é este repositório

Reusable workflows e composite actions de GitHub Actions, chamados por outros repositórios e fixados por SHA. Toda peça roda no pipeline de quem chama, então uma falha aqui se espalha. Segurança vem antes de conveniência.

| Assunto | Onde está |
|---|---|
| Estrutura e o que vai em cada pasta | [README, seção 1.2](README.md#12-estrutura-do-repositório) |
| Workflow ou action | [README, seção 1.3](README.md#13-workflow-ou-action) |
| Riscos OWASP CI/CD e pendências | [README, seção 2](README.md#2-segurança) |
| Como adicionar workflow, action ou workflow interno | [CONTRIBUTING, seção 3](CONTRIBUTING.md#3-adicionando-componentes) |
| Checklist de segurança | [CONTRIBUTING, seção 4](CONTRIBUTING.md#4-segurança) |
| Commits e pull requests | [CONTRIBUTING, seções 6 e 7](CONTRIBUTING.md#6-mensagens-de-commit) |
| Regras de `docs/` e esqueletos | [docs/README.md](docs/README.md) e [docs/_templates/](docs/_templates/README.md) |
| Decisões de arquitetura | [docs/adrs/](docs/adrs/README.md) |

## 2. Antes de mudar algo

- Leia o ADR do assunto em `docs/adrs/`. Não contradiga uma decisão aceita. Mudança de rumo é um ADR novo.
- Não crie pasta nova na raiz nem em `docs/`. O lugar de cada coisa está no README e em `docs/README.md`.
- Config de ferramenta deste repositório fica em `.github/config/`. Nunca em `docs/`.
- Não crie arquivo para outro projeto copiar. O padrão fica dentro do workflow.

## 3. Regras que valem para todo YAML

- Reusable workflow: arquivo solto em `.github/workflows/`, sem `_` no nome, só com `on: workflow_call`. Workflow interno começa com `_`.
- Composite action: `actions/<nome>/action.yaml`, com `README.md` gerado por `task github:action:docs`. Não edite o trecho entre os marcadores `action-docs-all`.
- `permissions: {}` no topo do workflow. Cada job declara só o que usa.
- Action de terceiros fixada por SHA completo, com a versão no comentário da mesma linha (`@<sha>  # v1.2.3`). O Dependabot depende desse formato.
- Binário baixado no job só roda depois de conferido por SHA256, com versão e checksum fixados no step.
- Input entra no script por `env:`, nunca por `${{ }}` dentro de `run:`. Sem `pull_request_target`.
- `persist-credentials: false` no checkout e `timeout-minutes` em todo job.
- Os nomes de job `scan`, `Action Lint`, `YAML Lint` e `Zizmor` são checks obrigatórios do ruleset. Renomear um deles bloqueia o merge.

## 4. Verificação

Rode antes de abrir o pull request. Todos precisam sair limpos:

```bash
actionlint
```

```bash
yamllint --strict -c .github/config/.yamllint.yaml .
```

```bash
task github:action:audit
```

Mudou uma composite action? Rode também `task github:action:docs`. As ferramentas vêm do `devbox.json` (`devbox shell`).

## 5. Release

- O merge na `main` é por squash. O título do pull request vira o commit e decide o tipo da versão, pelo Conventional Commits.
- O release é manual (`_release.yaml`) e só cria a tag `vX.Y.Z` e o GitHub Release. Não faz commit na `main`.
- O semantic-release roda em `.github/config/release/`, onde ficam a config e o lockfile. Atualize dependências pelo lockfile, nunca com `npm install` solto no workflow.
- Não crie tag móvel (`v1`) nem mova tag existente. Os releases são imutáveis.

## 6. Escrita

- Documentação em PT-BR com acento. Código, nomes de input, config e commits em inglês.
- Sem travessão em nenhum texto. Use vírgula, ponto, dois-pontos ou parênteses.
- Nada pessoal: nenhum documento cita pessoas, contas, outros repositórios do dono ou configurações locais. O texto vale para qualquer leitor.
- Documento novo em `docs/` copia o esqueleto do tipo em `docs/_templates/` e segue o nome `tipo-nnn-titulo.md`.
