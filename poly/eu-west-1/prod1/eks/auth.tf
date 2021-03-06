
data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

# data "terraform_remote_state" "eks" {
#   backend = "s3"

#   config = {
#     bucket         = "liya-terraform-state"
#     dynamodb_table = "liya-terraform-lock-liya"
#     key            = "aws/eks/terraform.tfstate"
#     encrypt        = true
#     region         = var.aws_region
#   }
# }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
  # version                = "~> 1.11"
}
