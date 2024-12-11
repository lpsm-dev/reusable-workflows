<!-- BEGIN_DOCS -->

[◀ Voltar](../README.md)

<a name="readme-top"></a>

**Custom Actions**

</div>

# Sumário

- [Sumário](#sumário)
- [Concepts](#concepts)
- [➤ Templates ](#-templates-)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Concepts

If nothing in the GitHub Marketplace meets your requirements, you have the option to develop your own custom Action. This can be used internally within your organization or shared with others by publishing it to the Marketplace.

There are multiple ways to create custom Actions:

- Docker container Action
- JavaScript Action
- Composite Action

In this project we are using the idea of Composite actions.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# ➤ Templates <a name="#-templates"></a>

| Name                                | Description                                                                                         |
|-------------------------------------|-----------------------------------------------------------------------------------------------------|
| [aws-cloudfront](./actions/aws-cloudfront/README.md)   | Action to upload files to S3 and create a Cloudfront cache invalidation                               |
| [aws-ecr-build-push](./actions/aws-ecr-build-push/README.md) | Action to build and push a container image to AWS ECR                                              |
| [aws-ecr-create](./actions/aws-ecr-create/README.md)     | Action to create an ECR if it doesn't exist                                                         |
| [aws-eks-deploy](./actions/aws-eks-deploy/README.md)     | Action to update a Kubernetes deployment image in AWS EKS using Kubectl                              |
| [npm-build](./actions/npm-build/README.md)               | Action to build an NPM project                                                                      |
| [npm-install](./actions/npm-install/README.md)           | Action to run the NPM install command                                                               |
| [npm-load-cache](./actions/npm-load-cache/README.md)     | Action to load NPM cache from previous builds                                                       |
| [npm-run](./actions/npm-run/README.md)                   | Action to run a generic NPM command                                                                 |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- END_DOCS -->
