## Description

Action to update a Kubernetes deployment image in AWS EKS using Kubectl

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `aws-role-arn` | <p>The AWS Role to assume and execute actions in the pipeline that interact with AWS services</p> | `true` | `""` |
| `aws-region` | <p>The region in AWS that we will be working in</p> | `false` | `us-east-1` |
| `aws-session-name` | <p>The AWS session name to use when assuming the AWS Role</p> | `false` | `github-action-kubectl` |
| `eks-cluster-name` | <p>The name of the EKS cluster that is used to call kubeconfig with awscli</p> | `true` | `eks-develop-services` |
| `eks-namespace` | <p>The Kubernetes namespace of the application that is going to be deployed</p> | `true` | `default` |
| `app-name` | <p>The application name that is going to be deployed</p> | `true` | `""` |
| `image-name` | <p>The name of the application image that is going to be deployed</p> | `true` | `""` |
| `image-tag` | <p>The tag of the application image that is going to be deployed</p> | `true` | `latest` |
| `kubectl-version` | <p>The kubectl version to install</p> | `false` | `v1.29.1` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: ***PROJECT***@***VERSION***
  with:
    aws-role-arn:
    # The AWS Role to assume and execute actions in the pipeline that interact with AWS services
    #
    # Required: true
    # Default: ""

    aws-region:
    # The region in AWS that we will be working in
    #
    # Required: false
    # Default: us-east-1

    aws-session-name:
    # The AWS session name to use when assuming the AWS Role
    #
    # Required: false
    # Default: github-action-kubectl

    eks-cluster-name:
    # The name of the EKS cluster that is used to call kubeconfig with awscli
    #
    # Required: true
    # Default: eks-develop-services

    eks-namespace:
    # The Kubernetes namespace of the application that is going to be deployed
    #
    # Required: true
    # Default: default

    app-name:
    # The application name that is going to be deployed
    #
    # Required: true
    # Default: ""

    image-name:
    # The name of the application image that is going to be deployed
    #
    # Required: true
    # Default: ""

    image-tag:
    # The tag of the application image that is going to be deployed
    #
    # Required: true
    # Default: latest

    kubectl-version:
    # The kubectl version to install
    #
    # Required: false
    # Default: v1.29.1
```



