# Superfícies

Três superfícies. A decisão está no ADR [0001-layout](adrs/0001-layout.md).

O GitHub só executa workflow solto em `.github/workflows/`. Arquivo dentro de subdiretório dessa pasta fica de fora do `uses:`. Por isso [`gitleaks.yaml`](../.github/workflows/gitleaks.yaml) permanece onde está, e [`templates/`](../templates/) é o que um repositório novo copia uma vez.

## Workflows chamáveis

Arquivo solto em `.github/workflows/`, sem `_` no nome, com `workflow_call`. O chamável público é [`gitleaks.yaml`](../.github/workflows/gitleaks.yaml).

Os arquivos com `_` são o CI deste repositório: [`_ci.yaml`](../.github/workflows/_ci.yaml), [`_release.yaml`](../.github/workflows/_release.yaml) e [`_check-workflows.yaml`](../.github/workflows/_check-workflows.yaml). Quem chama de fora usa `gitleaks.yaml`.

## Composite actions

Uma pasta por action, com `action.yaml`. O catálogo está em [`actions/README.md`](../actions/README.md):

- [`aws-cloudfront-deploy`](../actions/aws-cloudfront-deploy/action.yaml)
- [`aws-ecr-create`](../actions/aws-ecr-create/action.yaml)
- [`aws-eks-deploy`](../actions/aws-eks-deploy/action.yaml)

## Templates

`templates/` fica fora do `uses:`. O repositório novo copia o arquivo, commita a cópia e segue com ela.

### Gitleaks

Copie [`templates/gitleaks.starter.toml`](../templates/gitleaks.starter.toml) para `.github/config/.gitleaks.toml` no repositório que chama o workflow.

O starter tem só isto:

```toml
[extend]
useDefault = true
```

A config viva deste repositório, [`.github/config/.gitleaks.toml`](../.github/config/.gitleaks.toml), tem o mesmo conteúdo. O input `config` aponta para esse caminho no caller. O padrão do input também é `.github/config/.gitleaks.toml`.

[`templates/.gitleaks.toml`](../templates/.gitleaks.toml) é um ruleset opcional, grande, com regras no padrão AzSK (Azure DevOps). O CI carrega o starter. Copie o ruleset AzSK só quando o projeto quiser essas regras a mais.

### semantic-release

[`templates/.releaserc.json`](../templates/.releaserc.json) é um starter de semantic-release. Cobre as branches `main` e `release` (prerelease `rc`) e os plugins `@semantic-release/commit-analyzer`, `@semantic-release/release-notes-generator`, `@semantic-release/gitlab`, `@semantic-release/changelog` e `@semantic-release/git`.

O release deste repositório lê [`.github/config/.releaserc.json`](../.github/config/.releaserc.json). O job [`_release.yaml`](../.github/workflows/_release.yaml) copia esse arquivo para a raiz antes do `semantic-release`. Essa config viva usa `@semantic-release/github` e só a branch `main`.

Para o mesmo fluxo no GitHub, copie `.github/config/.releaserc.json`. Use `templates/.releaserc.json` quando o release for no GitLab, ou quando quiser a branch `release` com `rc`.
