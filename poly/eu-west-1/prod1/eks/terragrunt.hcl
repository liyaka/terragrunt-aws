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
  environment  = local.env.locals.environment

}

dependency "secret" {
  config_path = "${get_parent_terragrunt_dir()}/${local.proj.locals.project}/${local.aws_region}/${local.environment}/secret"
}


dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.proj.locals.project}/${local.aws_region}/${local.environment}/vpc"
}

# dependency "ebsvolume" {
#   config_path = "${get_parent_terragrunt_dir()}/${local.account_name}/${local.environment}/${local.aws_region}/ebs"
# }

terraform {
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.vpc.outputs.public_subnets
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  kubernetes_kms_arn = dependency.secret.outputs.eks_kms_key_arn
  cluster_name       = local.cluster_name
  # volume_id          = dependency.ebsvolume.outputs.volume_id

  tags = {
    Terraform     = "true"
    Environment   = local.namespace
    TerraformPath = path_relative_to_include()
  }

}
