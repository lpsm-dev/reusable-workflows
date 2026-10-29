---
status: accepted
date: 2026-10-29
---

# Actions de ferramenta com workflows de compatibilidade

## 1. Contexto

### 1.1. Situação atual

Os reusable workflows de Gitleaks e semantic-release concentram a preparação do job e os comandos das ferramentas. O consumidor só consegue usá-los como jobs completos. As demais ferramentas do catálogo também podem ser chamadas como composite actions dentro de jobs próprios.

### 1.2. Problema

Como oferecer Gitleaks e semantic-release como steps sem quebrar os repositórios que já chamam os workflows públicos?

### 1.3. Drivers

- O consumidor pode combinar uma ferramenta com outros steps no mesmo job.
- O caminho e os inputs dos workflows públicos já são contratos de consumo.
- O projeto consumidor controla os plugins e o lockfile do semantic-release.

### 1.4. Restrições

- O workflow de Gitleaks mantém o check `scan` exigido pelo ruleset.
- Os downloads de binários passam por verificação SHA256.
- O `actionlint` adotado neste projeto ainda não reconhece a referência `$/` do GitHub.

## 2. Decisão

Cada ferramenta terá uma composite action com a lógica de instalação e execução. Os workflows públicos continuarão preparando checkout, runner, permissões e condição de branch. Eles chamarão as actions por SHA completo depois que as actions estiverem publicadas na `main`. Não haverá segunda implementação dos comandos nos workflows.

O Gitleaks examina o conteúdo versionado em `HEAD` e preserva a busca atual de configuração. O semantic-release instala as dependências do lockfile mantido pelo consumidor. A action exige o token pelo ambiente do step e bloqueia publicação fora da branch informada. O workflow mantém sua condição atual e ignora jobs fora dessa branch.

## 3. Opções consideradas

### 3.1. Apenas workflows

Mantém um único caminho de manutenção, mas impede o uso das ferramentas como steps de um job existente. **Rejeitada.**

### 3.2. Actions com workflows que as chamam

Oferece os dois modos de consumo com uma implementação da ferramenta. Exige atualizar o SHA da action em cada workflow quando ela mudar. **Adotada.**

### 3.3. Referência `$/` no workflow

O GitHub resolveria a action no mesmo commit do workflow, inclusive para consumidores externos. O `actionlint` atual rejeita essa sintaxe. **Adiada** até que o gate do projeto a reconheça.

## 4. Trade-offs aceitos

| Trade-off | Impacto | Mitigação |
| --- | --- | --- |
| A action precisa ser publicada antes de o workflow fixar seu SHA | A migração ocorre em dois merges | Testar o segundo PR com um consumidor externo antes do merge |
| O wrapper fixa um commit anterior da action | Atualizações das actions não chegam automaticamente aos wrappers | Atualizar o SHA do wrapper em PR próprio, com teste de integração |
| O consumidor direto controla o job | Checkout e permissões passam a ser responsabilidade dele | Documentar exemplos completos nas páginas das actions |

## 5. Consequências

### 5.1. Positivas

- O consumidor pode escolher entre um step e um job completo.
- Os workflows existentes mantêm caminho, inputs e nomes de jobs.
- As verificações de segurança das ferramentas têm um único lugar de manutenção.

### 5.2. Negativas

- O ciclo de atualização do wrapper exige um PR adicional enquanto o `actionlint` não aceitar `$/`.

## 6. Referências

- [ADR de layout](adr-001-layout.md).
- [ADR de configuração por projeto](adr-004-remove-templates.md).
- [GitHub, referência de actions do mesmo repositório](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idstepsuses).
