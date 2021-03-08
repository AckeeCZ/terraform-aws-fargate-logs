# Terraform AWS Fargate logging to CloudWatch

In case you'd like to log from your Fargate pods directly to CloudWatch, use this module. It's an implementation of
this article https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html 

This setup is used for JSON logs, in case your application does not logging in JSON, adjust the `parsers.conf` file.

## Before you do anything in this module

Install pre-commit hooks by running following commands:

```shell script
brew install pre-commit terraform-docs
pre-commit install
```

## Terragrunt snippet

In case you would like to use the module in Terragrunt setup, don't forget to initialize with correct providers:

```hcl
# setup local variables, this part is omitted
# ...
# ...

dependency "eks" {
    config_path = "../eks/"  # eks module from git::git@github.com:terraform-aws-modules/terraform-aws-eks.git?ref=v14.0.0
}

terraform {
  source  = ".//eks-fargate-logging"  # use public terraform registry
}

include {
  path = find_in_parent_folders()
}
        
inputs = {
  project           = "fabulous-project"
  fargate_role_name = dependency.eks.outputs.fargate_iam_role_name
  region            = local.region_vars.locals.aws_region
}

generate "k8s_provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    data "aws_eks_cluster" "cluster" {
      name = "${dependency.eks.outputs.cluster_id}"
    }

    data "aws_eks_cluster_auth" "cluster" {
      name = "${dependency.eks.outputs.cluster_id}"
    }

    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }
    EOF
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = "= 0.13.5"
    }
    provider "aws" {
      region = "${local.region_vars.locals.aws_region}"
      # Only these AWS Account IDs may be operated on by this template
      allowed_account_ids = ["${local.account_vars.locals.aws_account_id}"]
    }
    EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      required_providers {
        aws        = "3.27.0"
        kubernetes = "2.0.2"
      }
    }
    EOF
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | 3.27.0 |
| kubernetes | 2.0.2 |

## Providers

| Name | Version |
|------|---------|
| aws | 3.27.0 |
| kubernetes | 2.0.2 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/3.27.0/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/3.27.0/docs/data-sources/iam_policy_document) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/3.27.0/docs/resources/iam_role_policy_attachment) |
| [kubernetes_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/2.0.2/docs/resources/config_map) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/2.0.2/docs/resources/namespace) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| fargate\_role\_name | Role name assigned to fargate pod runtime, used here to enable access to CloudWatch logging | `any` | n/a | yes |
| project | Project name, e.g. customer-portal, used for cloudwatch entities names | `any` | n/a | yes |
| region | AWS region where EKS is running | `any` | n/a | yes |

## Outputs

No output.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->