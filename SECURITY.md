# Política de segurança

## 1. Versões suportadas

Só a versão mais recente recebe correção. Quem chama este repositório fixa um SHA, então a correção chega quando o projeto troca o SHA pelo da nova versão. A lista de versões fica nos [GitHub Releases](https://github.com/lpsm-dev/reusable-workflows/releases).

## 2. Como reportar uma vulnerabilidade

Não abra issue pública para falha de segurança. Use o reporte privado do GitHub:

1. Abra a aba [Security](https://github.com/lpsm-dev/reusable-workflows/security) do repositório.
2. Clique em **Report a vulnerability**.
3. Descreva o workflow ou a action afetada, o SHA usado e como reproduzir.

O fluxo está descrito em [Privately reporting a security vulnerability](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability).

## 3. O que entra no escopo

- Os reusable workflows em `.github/workflows/` sem prefixo `_`.
- As composite actions em `actions/`.
- Qualquer caminho que exponha token, segredo ou código de quem chama, conforme o [OWASP Top 10 CI/CD Security Risks](https://owasp.org/projects/top-10-cicd-security-risks).
