# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  aws_region = "eu-west-1"

  # Prod1 VPC
  prod1_vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  prod1_vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

}
