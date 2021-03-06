# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account.locals.account_name
  account_id   = local.account.locals.aws_account_id
  aws_region   = local.region.locals.aws_region

  namespace = "${local.proj.locals.project}-${local.env.locals.environment}"

  cluster_name = "${local.proj.locals.project}-${local.env.locals.environment}"

  private_subnets = local.env.locals.vpc_private_subnets
  public_subnets  = local.env.locals.vpc_public_subnets

}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc?ref=v2.47.0"
}


inputs = {
  name = local.namespace
  cidr = "10.0.0.0/16"

  azs = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets  = ["10.0.101.0/24"]
  private_subnets = "${local.private_subnets}"
  public_subnets  = "${local.public_subnets}"

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Cloudwatch log group and IAM role will be created
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  vpc_flow_log_tags = {
    Name = "${local.namespace}-vpc-flow-logs-cloudwatch-logs"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    Terraform     = "true"
    Environment   = local.namespace
    TerraformPath = path_relative_to_include()
  }

}
