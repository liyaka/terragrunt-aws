variable "vpc_id" {}
variable "cluster_name" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "kubernetes_kms_arn" {}
variable "aws_region" {
  type = string
}
# variable "volume_id" {}
