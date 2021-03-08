variable "region" {
  description = "AWS region where EKS is running"
}

variable "project" {
  description = "Project name, e.g. customer-portal, used for cloudwatch entities names"
}

variable "fargate_role_name" {
  description = "Role name assigned to fargate pod runtime, used here to enable access to CloudWatch logging"
}
