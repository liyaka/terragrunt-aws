output "cluster_id" {
  value = module.eks-cluster.cluster_id
}
output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = module.eks-cluster.kubeconfig
}
output "worker_iam_role_name" {
  value = module.eks-cluster.worker_iam_role_name
}
output "cluster_oidc_issuer_url" {
  value = module.eks-cluster.cluster_oidc_issuer_url
}
output "oidc_provider_arn" {
  value = module.eks-cluster.oidc_provider_arn
}