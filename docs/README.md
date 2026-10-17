# docs

Índice da documentação deste repositório. A pasta é o tipo do documento.

A ordem das seções segue o nome: pasta com `_` vem antes das outras.

Idioma: PT-BR, com acento. Sem travessão. Nome de arquivo em kebab-case, sem acento.

Documento de um tipo se chama `tipo-nnn-titulo.md`. O tipo é `adr`, `rfc`, `research`, `handbook` ou `runbook`. `nnn` tem três dígitos e começa em `001`. A ordem é a `date`, crescente. No mesmo dia, o título. Entrar, sair ou mudar a data recalcula a sequência desde `001` e atualiza os links. Índice, inbox, assets e esqueleto ficam de fora.

## 1. Regra

Um documento responde uma pergunta. A promoção sai da inbox para pesquisa, RFC, ADR, handbook ou runbook. Documento curado permanece no tipo em que entrou.

Não são pasta: guide, how-to, tutorial, reference, playbook, SOP, policy, archive, project. Por isso a página de cada reusable workflow é um handbook, e não uma pasta `workflows/`. A decisão está em [adrs/adr-006-docs-taxonomy.md](adrs/adr-006-docs-taxonomy.md).

O README de cada composite action fica ao lado do `action.yaml`, em `actions/<nome>/`, porque é gerado a partir dele. Config de ferramenta fica em `.github/config/`. Nenhum dos dois entra em `docs/`.

Todo documento segue o esqueleto do seu tipo, em `_templates/`.

A pasta é o tipo. O frontmatter não repete o tipo. Pesquisa, RFC, ADR, handbook e runbook abrem com `date` (`YYYY-MM-DD`). ADR, RFC e runbook também levam `status`. Inbox não leva frontmatter. Fora: `type`, `id`, `version`, `tags`, `related_docs`, `review_date`. O detalhe está no README de cada pasta.

## 2. _assets/

Mídia usada por mais de um documento. Não é um tipo de documento. Formato em [_assets/README.md](_assets/README.md).

## 3. _inbox/

Caixa de entrada. O documento fica aqui até ser curado. Formato em [_inbox/README.md](_inbox/README.md).

## 4. _templates/

Esqueleto de cada tipo. Copiar para a pasta do tipo e preencher. Formato em [_templates/README.md](_templates/README.md).

## 5. adrs/

Decisões. Formato e índice em [adrs/README.md](adrs/README.md).

## 6. handbooks/

Explicação de um assunto. Aqui, a página de cada reusable workflow. Índice em [handbooks/README.md](handbooks/README.md).

## 7. research/

Leitura e fontes. Índice em [research/README.md](research/README.md).

## 8. rfcs/

Propostas antes da decisão. Formato em [rfcs/README.md](rfcs/README.md).

## 9. runbooks/

Procedimento: condição, passos e verificação. Formato em [runbooks/README.md](runbooks/README.md).
