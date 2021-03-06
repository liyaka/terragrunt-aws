locals {
  prod1_region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = "prod1"

  # VPC VARIABLES
  vpc_private_subnets = local.prod1_region_vars.locals.prod1_vpc_private_subnets
  vpc_public_subnets  = local.prod1_region_vars.locals.prod1_vpc_public_subnets

}
