---
status: proposed
date: YYYY-MM-DD
---

# Título curto

> Guia: apague este bloco e os outros blocos Guia ao preencher.
>
> Use para propor uma mudança que ainda precisa de deliberação: arquitetura, processo, tecnologia nova, ou risco operacional que vale uma leitura antes de decidir.
>
> Não use para decisão já tomada (isso é ADR), mudança fácil de desfazer, ou correção pontual.
>
> A RFC propõe. Se for aceita, nasce um ADR e esta RFC ganha o link. A RFC não é reescrita como se fosse a decisão.
>
> Frontmatter: `status` (`proposed`, `accepted`, `rejected`) e `date`. Rascunho e revisão são `proposed`. Proposta abandonada fica `rejected`, com o motivo no corpo. Sem `type`, `version`, autor ou aprovador.
>
> A forma vem das RFC da HashiCorp, da Shopify e do Rust, cortada para um operador só.

## 1. Resumo

Uma a três frases do que se propõe. Sem justificativa e sem detalhe de implementação.

## 2. Background

> Guia: um recém-chegado lê esta seção, segue os links, e fica com o contexto. Se precisar de mais de dois links externos para entender, a seção está curta.

Situação atual e o limite dela. O que motivou a proposta. ADR ou RFC anterior, se houver.

## 3. Proposta

O que muda, em nível de arquitetura. O bastante para avaliar sem ambiguidade. Sem descer ao código.

### 3.1. Escopo

**Dentro:**

- Item.

**Fora:**

- Item, e o motivo.

### 3.2. Design

Fluxo, contrato ou schema. Mermaid se a forma ajudar. A ordem constrói o entendimento.

> Guia: plano de migração só se existir estado para sair. Fases, rollback, e o que autoriza seguir ou voltar. Apague este bloco se não houver migração.

## 4. Alternativas consideradas

> Guia: no mínimo uma alternativa além da proposta, com descarte concreto. Inclua não fazer nada.

### 4.1. Alternativa A

Descrição.

**Descartada porque** a razão é concreta.

### 4.2. Não fazer nada

O que acontece se o estado atual permanecer. Se isso for aceitável, esta RFC provavelmente não é necessária.

## 5. Desvantagens

Razões honestas para não fazer. Se a proposta muda superfície de ataque, diga aqui.

- **Desvantagem:** impacto e mitigação.

## 6. Questões em aberto

### 6.1. Antes do aceite

- [ ] Questão que bloqueia a decisão.

### 6.2. Durante a implementação

- [ ] Questão que não bloqueia o aceite.

## 7. Referências

- ADR relacionada.
- RFC anterior.
- Fonte externa.
