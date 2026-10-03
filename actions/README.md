<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<a name="readme-top"></a>

**Custom Actions**

</div>

# Sumário

- [Sumário](#sumário)
- [Concepts](#concepts)
- [Actions](#actions)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Concepts

If nothing in the GitHub Marketplace meets your requirements, you have the option to develop your own custom Action. This can be used internally within your organization or shared with others by publishing it to the Marketplace.

There are multiple ways to create custom Actions:

- Docker container Action
- JavaScript Action
- Composite Action

In this project we are using the idea of Composite actions.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Actions

| Name | Path | Description |
| --- | --- | --- |
| aws-cloudfront-deploy | [`actions/aws-cloudfront-deploy/action.yaml`](./aws-cloudfront-deploy/action.yaml) | Action to upload files to S3 and create a Cloudfront cache invalidation |
| aws-ecr-create | [`actions/aws-ecr-create/action.yaml`](./aws-ecr-create/action.yaml) | Action to create an ECR if it doesn't exist |
| aws-eks-deploy | [`actions/aws-eks-deploy/action.yaml`](./aws-eks-deploy/action.yaml) | Action to update a Kubernetes deployment image in AWS EKS using Kubectl |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_DOCS -->
