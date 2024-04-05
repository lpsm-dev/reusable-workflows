## Description

Action to create an ECR if doesn't exist

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `aws-region` | <p>The region in AWS that we will be working in</p> | `false` | `us-east-1` |
| `repository-name` | <p>The name of the repository that is to be created in ECR</p> | `true` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: ***PROJECT***@***VERSION***
  with:
    aws-region:
    # The region in AWS that we will be working in
    #
    # Required: false
    # Default: us-east-1

    repository-name:
    # The name of the repository that is to be created in ECR
    #
    # Required: true
    # Default: ""
```



