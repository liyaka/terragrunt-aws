resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

output "eks_kms_key_arn" {
  value = aws_kms_key.eks.arn
}