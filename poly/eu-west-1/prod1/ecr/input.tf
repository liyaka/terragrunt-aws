variable "enabled_ecr" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "max_image_count" {
  type        = number
  default     = 10
  description = "How many Docker Image versions AWS ECR will store."
}

variable "principals_readonly_access" {
  type        = list
  default     = []
  description = "Principal ARN to provide with readonly access to the ECR."
}

variable "name" {
  type  = string
}

variable "aws_region" {
  type  = string
}

variable "principals_full_access" {
  type        = list
  description = "Principal ARN to provide with full access to the ECR."
  default     = []
}
