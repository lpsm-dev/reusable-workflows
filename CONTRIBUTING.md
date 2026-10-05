<!-- BEGIN_DOCS -->

[◀ Voltar](README.md)

<div align="center">

<a name="readme-top"></a>

<img alt="contributing" src="https://github.com/lpsm-dev/lpsm-dev/blob/98272299ea611ba50254b132490ea385149dc5cf/.github/assets/contributing.png" width="225"/>

**Diretrizes para o processo de contribuição**

</div>

Seja bem-vindo e obrigado por considerar contribuir com este projeto! Ler e seguir nossas diretrizes vai te ajudar a entrar com mais rapidez no nosso fluxo de trabalho, além de tornar o processo de contribuição mais fácil e eficaz. Contamos com seu apoio!

<!-- START_TABLE_OF_CONTENTS -->

[1. Práticas](#1-práticas)<br>
&nbsp;&nbsp;&nbsp;[1.1. Geral](#11-geral)<br>
&nbsp;&nbsp;&nbsp;[1.2. Comunicação](#12-comunicação)<br>
[2. Setup](#2-setup)<br>
&nbsp;&nbsp;&nbsp;[2.1. Devbox](#21-devbox)<br>
&nbsp;&nbsp;&nbsp;[2.2. Direnv](#22-direnv)<br>
&nbsp;&nbsp;&nbsp;[2.3. Task](#23-task)<br>
[3. Adicionando componentes](#3-adicionando-componentes)<br>
&nbsp;&nbsp;&nbsp;[3.1. Reusable workflow](#31-reusable-workflow)<br>
&nbsp;&nbsp;&nbsp;[3.2. Composite action](#32-composite-action)<br>
&nbsp;&nbsp;&nbsp;[3.3. Workflow interno](#33-workflow-interno)<br>
[4. Padrão de documentação](#4-padrão-de-documentação)<br>
[5. Mensagens de commit](#5-mensagens-de-commit)<br>
&nbsp;&nbsp;&nbsp;[5.1. Tipo](#51-tipo)<br>
&nbsp;&nbsp;&nbsp;[5.2. Escopo](#52-escopo)<br>
&nbsp;&nbsp;&nbsp;[5.3. Descrição](#53-descrição)<br>
[6. Pull requests](#6-pull-requests)<br>
&nbsp;&nbsp;&nbsp;[6.1. Passo a passo](#61-passo-a-passo)<br>
&nbsp;&nbsp;&nbsp;[6.2. Revisão](#62-revisão)<br>
[7. Versionamento](#7-versionamento)<br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_TABLE_OF_CONTENTS -->

# 1. Práticas

## 1.1. Geral

- Se você não conseguir continuar uma tarefa, informe imediatamente sua equipe. A comunicação rápida evita atrasos e permite que outras pessoas te ajudem a resolver os problemas com mais rapidez.
- Não reinvente a roda. Se você pesquisou e viu que já existe uma solução bem estabelecida para o seu problema, use-a. Isso economiza tempo e recurso.

## 1.2. Comunicação

- Minimize o uso de IA na comunicação diária com a equipe. Valorizamos interações reais e genuínas.
- Seja objetivo na sua comunicação quando precisar de ajuda (isso não significa ser rude rsrs).
- A comunicação assíncrona é uma grande aliada para equipes remotas. Para mais detalhes, clique [aqui](https://nohello.net/en/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 2. Setup

As ferramentas de linha de comando deste repositório (`actionlint`, `yamllint`, `gitleaks`, `task`, `pre-commit` e `act`) estão declaradas no [devbox.json](devbox.json). As etapas abaixo deixam tudo pronto em poucos comandos.

## 2.1. Devbox

O **Devbox** é uma ferramenta CLI que cria ambientes de desenvolvimento isolados e reproduzíveis, sem precisar usar containers Docker ou a linguagem Nix de forma nativa.

> [!NOTE]
> Use essa opção se você não quiser instalar muitas ferramentas CLI diretamente em seu ambiente de trabalho.

- Instale o [devbox](https://www.jetify.com/docs/devbox/installing-devbox):

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

- Na raiz do repositório, abra o shell com as ferramentas do projeto:

```bash
devbox shell
```

Com isso, todos no projeto usam as mesmas ferramentas, nas mesmas versões.

## 2.2. Direnv

O **Direnv** ajusta o seu shell conforme o diretório atual. Neste repositório, o [.envrc](.envrc) abre o shell do **Devbox** sempre que você entra na pasta do projeto.

- Acesse a documentação do [direnv](https://direnv.net/docs/installation.html) e siga as instruções para instalá-lo.
- Na primeira vez que entrar na pasta, e sempre que o `.envrc` mudar, autorize o arquivo:

```bash
direnv allow
```

## 2.3. Task

A ferramenta **task** define e executa as tarefas do projeto, de forma parecida com o `make`. Ela já vem no **Devbox**. Se preferir instalar à parte, siga a documentação do [task](https://taskfile.dev/installation/).

Execute `task` na raiz do repositório para listar os comandos. Os mais usados:

| Comando | O que faz |
| --- | --- |
| `task precommit:init` | Instala os hooks do pre-commit, incluindo a validação da mensagem de commit |
| `task yamllint` | Valida os arquivos YAML com a config de `.github/config/.yamllint.yaml` |
| `task github:action:lint` | Roda o `actionlint` nos workflows |
| `task github:action:docs` | Gera o `README.md` de cada composite action a partir do `action.yaml` |
| `task gitleaks` | Procura segredos no histórico do repositório com as regras padrão do Gitleaks |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 3. Adicionando componentes

Antes de criar algo, veja em [Estrutura do repositório](README.md#12-estrutura-do-repositório) onde cada tipo de peça fica.

## 3.1. Reusable workflow

1. Crie o arquivo direto em `.github/workflows/`, sem subpasta e sem `_` no início do nome, por exemplo `.github/workflows/terraform-plan.yaml`. O GitHub não encontra reusable workflows em subpastas.
2. Use `on: workflow_call` como único gatilho e declare `permissions` mínimas.
3. Fixe toda action de terceiros pelo SHA completo, com a versão num comentário (`# v7.0.1`).
4. Se a ferramenta usa um arquivo de config, faça o workflow funcionar sem ele, com o padrão da ferramenta, e aceite o caminho num input opcional. Não crie arquivo para o projeto copiar: exemplos opcionais ficam na pasta do workflow, como o [`azsk.toml`](docs/workflows/gitleaks/azsk.toml) do Gitleaks.
5. Escreva a página do workflow em `docs/workflows/<nome>/README.md`, seguindo o modelo de [`docs/workflows/gitleaks/README.md`](docs/workflows/gitleaks/README.md).
6. Adicione uma linha na tabela de [reusable workflows](README.md#21-reusable-workflows) do README.
7. Teste antes do merge. Se o workflow fizer sentido para este repositório, chame-o no [`_ci.yaml`](.github/workflows/_ci.yaml) pelo caminho relativo (`uses: ./.github/workflows/<nome>.yaml`), que roda a versão do próprio branch. Se não fizer, chame-o de um repositório de teste apontando para o SHA do seu branch.

> [!WARNING]
> Dentro de um reusable workflow, o contexto `github` é o do repositório que chama. Um `uses: ./actions/<nome>` procura a action no workspace, que tem o código de quem chama, e não o deste repositório. Para usar uma composite action daqui, referencie `lpsm-dev/reusable-workflows/actions/<nome>@<sha-completo>`.

## 3.2. Composite action

1. Crie `actions/<nome>/action.yaml` com `runs.using: composite`. Use kebab-case e comece o nome pelo provedor ou pela ferramenta, como em `aws-ecr-create`.
2. Passe inputs para scripts via `env:` em vez de interpolar `${{ inputs.<nome> }}` direto no `run:`. Interpolação direta abre espaço para [injeção de script](https://docs.github.com/en/actions/reference/security/secure-use#good-practices-for-mitigating-script-injection-attacks).
3. Rode `task github:action:docs`. A task cria o `actions/<nome>/README.md` com os marcadores do action-docs e gera descrição, entradas e exemplo de uso a partir do `action.yaml`.
4. Adicione uma linha no [catálogo de actions](actions/README.md#2-catálogo) e na tabela de [composite actions](README.md#22-composite-actions) do README.

## 3.3. Workflow interno

Automação que serve só a este repositório, como CI e release, fica em `.github/workflows/` com `_` no início do nome: `_ci.yaml` (Gitleaks), `_check-workflows.yaml` (actionlint e yamllint) e `_release.yaml` (semantic-release). A configuração das ferramentas desses workflows fica em `.github/config/` e serve só a este repositório: não é modelo para outros projetos copiarem. Nada de fora deve chamar esses arquivos.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 4. Padrão de documentação

- A documentação é escrita em português. Código, nomes de inputs e descrições dentro do `action.yaml` ficam em inglês.
- Os documentos escritos à mão (READMEs, este guia e as páginas em `docs/workflows/<nome>/README.md`) seguem o esqueleto abaixo: marcadores `BEGIN_DOCS` e `END_DOCS`, âncora `readme-top`, link "◀ Voltar" para a página de cima (menos no README raiz), seções numeradas (`# 1. Visão Geral`, `## 1.1. Objetivo`) e o link "back to top" no fim de cada seção `#`.
- O sumário fica entre os marcadores `START_TABLE_OF_CONTENTS` e `END_TABLE_OF_CONTENTS`. Quem gera o sumário e a numeração das seções é o [gtoc](https://github.com/lpsm-dev/gtoc): escreva os títulos sem número e rode `gtoc generate --number-headings <arquivo>.md`. Links para seções usam a âncora numerada, como `#12-estrutura-do-repositório`.
- Não escreva os comentários HTML desses marcadores em código inline no meio do texto. O gtoc trata a linha como sumário e deixa de numerar todas as seções seguintes. Dentro de bloco de código, como no esqueleto, não há problema.
- Os `README.md` das composite actions são gerados pelo `task github:action:docs`. Não edite o trecho entre os marcadores `action-docs-all` à mão.
- ADRs ficam em `docs/adrs/NNNN-<titulo>.md`, com front matter (`status` e `date`) e as seções Contexto, Decisão, Opções consideradas e Consequências.

Esqueleto de uma página nova:

```markdown
<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<div align="center">

<a name="readme-top"></a>

**Título da página**

</div>

<!-- START_TABLE_OF_CONTENTS -->
<!-- END_TABLE_OF_CONTENTS -->

# Visão Geral

Texto da seção.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 5. Mensagens de commit

Nesse projeto, exigimos que **todos os commits** sigam um formato específico de mensagem, o [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Com isso, conseguimos:

- **Clareza e consistência**: as mensagens de commit seguem um formato padrão, facilitando a leitura e a compreensão das mudanças.
- **Automatização**: permite automatizar a geração de changelog, o versionamento semântico e os releases.
- **Rastreamento de alterações**: facilita identificar o que foi modificado ao longo do tempo, e por quê.
- **Revisão de código**: as mudanças chegam descritas de forma clara e padronizada.
- **Comunicação**: todos entendem rapidamente o contexto e o propósito de cada alteração.

Veja como é organizado esse formato de commits:

```txt
<type>(optional scope): <description>

[optional body]
```

## 5.1. Tipo

Descreve o tipo de alteração do commit. Temos as seguintes opções:

| Tipo | Descrição |
| --- | --- |
| **feat** | Um novo recurso (um novo workflow, uma nova action, um input novo em um componente existente etc.). |
| **fix** | Uma correção de bug. Ao atualizar dependências que não sejam de desenvolvimento, marque suas alterações como `fix`. |
| **docs** | Alterações somente na documentação. |
| **style** | Alterações que não afetam o significado do código (espaços em branco, formatação etc.). |
| **refactor** | Uma alteração de código que não corrige um bug nem adiciona um recurso. |
| **perf** | Uma alteração de código que melhora o desempenho. |
| **test** | Adição de testes ausentes ou correção de testes existentes. |
| **build** | Alterações que afetam o sistema de build. |
| **ci** | Alterações em arquivos e scripts de configuração de CI/CD deste repositório. |
| **chore** | Outras alterações que não modificam arquivos de origem ou de teste. Use esse tipo ao adicionar ou atualizar dependências de desenvolvimento. |
| **revert** | Reverte um commit anterior. |

## 5.2. Escopo

É qualquer coisa que forneça informações adicionais ou que especifique o local da alteração. Neste repositório, o escopo costuma ser o nome do componente, como `gitleaks`, `aws-eks-deploy` ou `task`. Cada tipo (`type`) de commit pode ter um escopo (`scope`) opcional, e cabe a você adicionar ou omitir essa informação. Por exemplo:

```txt
feat(gitleaks): add config input
```

> [!NOTE]
> Use letras minúsculas e kebab-case no escopo, como nos commits que já existem: `feat(gitleaks)`, `docs(layout)`, `chore(deps)`.

## 5.3. Descrição

É o campo onde você diz o que foi feito no commit, de forma breve. Para isso, recomendamos que:

- Priorize descrições em inglês.
- Use o imperativo, no tempo presente: "change", não "changed" nem "changes".
- Não coloque a primeira letra em maiúscula.
- Não coloque ponto (.) no final.

> [!NOTE]
> Cada tipo de commit tem um efeito sobre a próxima release que você for lançar.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 6. Pull requests

Ao criar um pull request (PR), defina o título seguindo a mesma convenção das mensagens de commit. Como o merge é feito com **squash**, o título do PR vira a mensagem final do commit na `main`, e o histórico fica enxuto e linear.

## 6.1. Passo a passo

- Crie uma branch a partir da branch `main`:

```bash
git checkout main
git pull origin main
git checkout -b sua-nova-branch
```

- Trabalhe na branch criada:
  - Realize as alterações necessárias e faça os commits das mudanças.
  - Certifique-se de que seu código atenda os padrões de qualidade estabelecidos.
  - Garanta que seus commits sigam a convenção de commits definida acima.

```bash
git add .
git commit -m "fix: change the commit"
```

- Faça o push da sua branch:

```bash
git push origin sua-nova-branch
```

- Abra o PR:
  - No GitHub, abra um pull request da sua branch para a branch `main`.
  - Adicione uma descrição clara do que foi feito e qualquer informação relevante para a revisão.
  - Defina o título usando commits convencionais.

- Revisão e aprovação:
  - Um mantenedor revisará seu código.
  - Se o código atender aos requisitos e padrões, ele será aprovado.
  - Após a aprovação, o PR é mesclado na `main` com squash.

- Finalização:
  - Após a mesclagem, apague a sua branch se ela não for mais necessária.
  - Execute `git pull` na branch `main`.

Seguir este processo garante que as alterações sejam revisadas adequadamente e que a `main` permaneça estável.

## 6.2. Revisão

Durante a revisão do PR, siga essas políticas:

- Seja respeitoso e construtivo.
- Sempre realize a revisão em pares.
- Sugira alterações em vez de simplesmente comentar os problemas encontrados.
- Exigimos pelo menos um aprovador no PR, que não seja o autor.
- Se não tiver certeza sobre algo, pergunte ao autor do PR.
- Se você estiver satisfeito com as alterações, aprove o PR.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 7. Versionamento

Este projeto segue a especificação [SemVer](https://semver.org/). O release é manual: o workflow [`_release.yaml`](.github/workflows/_release.yaml) roda o semantic-release na `main`, cria a tag e atualiza o [CHANGELOG.md](CHANGELOG.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<!-- END_DOCS -->
