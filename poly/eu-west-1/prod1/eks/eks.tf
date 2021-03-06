module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.18"
  subnets         = var.private_subnet_ids
  vpc_id          = var.vpc_id
  # enable_irsa     = true


  cluster_encryption_config = [
    {
      provider_key_arn = var.kubernetes_kms_arn
      resources        = ["secrets"]
    }
  ]

  # tags = {
  #   GithubRepo = "terraform-aws-eks"
  #   GithubOrg  = "terraform-aws-modules"
  # }

  map_users = [
    {
      userarn  = "arn:aws:iam::329054710135:user/liya@tikalk.com"
      username = "liya"
      groups   = ["system:masters"]
    },
  ]

  worker_groups_launch_template = [

    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    },
    # {
    #   name                          = "worker-group-2"
    #   instance_type                 = "t2.medium"
    #   additional_userdata           = "echo foo bar"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    #   asg_desired_capacity          = 1
    # },
    # {
    #   name                    = "spot-1"
    #   override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
    #   spot_instance_pools     = 4
    #   asg_max_size            = 5
    #   asg_desired_capacity    = 5
    #   kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
    #   public_ip               = true
    # },
  ]



}



resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "worker_group_mgmt"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}
# resource "kubernetes_csi_driver" "example" {
#   metadata {
#     name = "terraform-example"
#   }

#   spec {
#     attach_required        = true
#     pod_info_on_mount      = true
#     volume_lifecycle_modes = ["Ephemeral"]
#   }

# }

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}
# resource "kubernetes_namespace" "jenkins" {
#   metadata {
#     name = "jenkins"
#   }
# }

# resource "kubernetes_storage_class" "gp2-retain" {
#   metadata {
#     name = "gp2-retain"
#   }
#   storage_provisioner = "kubernetes.io/aws-ebs"
#   reclaim_policy      = "Retain"
# }

# resource "kubernetes_persistent_volume" "pv-jenkins" {
#   metadata {
#     name = "pv-jenkins"
#   }
#   spec {
#     capacity = {
#       storage = "80Gi"
#     }
#     storage_class_name = "gp2-retain"
#     access_modes       = ["ReadWriteMany"]
#     persistent_volume_source {
#       aws_elastic_block_store {
#         volume_id = var.volume_id
#         fs_type   = "ext4"
#       }
#     }
#   }
# }
# resource "kubernetes_persistent_volume_claim" "pvc-jenkins" {
#   wait_until_bound = false
#   metadata {
#     name      = "pvc-jenkins"
#     namespace = "jenkins"
#   }
#   spec {
#     storage_class_name = "gp2-retain"
#     access_modes       = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "80Gi"
#       }
#     }
#     volume_name = kubernetes_persistent_volume.pv-jenkins.metadata.0.name
#   }
#
# }
