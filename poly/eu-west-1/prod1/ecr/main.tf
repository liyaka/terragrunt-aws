
locals {
  principals_readonly_access_non_empty = length(var.principals_readonly_access) > 0 ? true : false
  principals_full_access_non_empty     = length(var.principals_full_access) > 0 ? true : false
  ecr_need_policy                      = length(var.principals_full_access) + length(var.principals_readonly_access) > 0 ? true : false

}

resource "aws_ecr_repository" "default" {
  count = var.enabled_ecr ? 1 : 0
  name  = var.name

  image_scanning_configuration {
    # scan_on_push = "true"
    scan_on_push = "false"
  }
}

# module "ecr_lifecycle_rule_tagged_image_count_30" {
#   source = "doingcloudright/ecr-lifecycle-policy-rule/aws"
#   version = "1.0.0"
#
#   tag_status = "tagged"
#   count_type = "imageCountMoreThan"
#   prefixes  = ["test","uat","prod"]
#   count_number = 30
# }
#
# module "ecr_lifecycle_rule_untagged_100_days_since_image_pushed" {
#   source = "doingcloudright/ecr-lifecycle-policy-rule/aws"
#   version = "1.0.0"
#
#   tag_status = "untagged"
#   count_type = "sinceImagePushed"
#   count_number = "100"
# }

resource "aws_ecr_lifecycle_policy" "default" {
  count      = var.enabled_ecr ? 1 : 0
  repository = join("", aws_ecr_repository.default.*.name)

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "empty" {
}

data "aws_iam_policy_document" "resource_readonly_access" {
  statement {
    sid    = "ReadonlyAccess"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = var.principals_readonly_access
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]
  }
}

data "aws_iam_policy_document" "resource_full_access" {
  statement {
    sid    = "FullAccess"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = var.principals_full_access
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]
  }
}


data "aws_iam_policy_document" "resource" {
  source_json   = local.principals_readonly_access_non_empty ? join("", data.aws_iam_policy_document.resource_readonly_access.*.json) : join("", data.aws_iam_policy_document.empty.*.json)
  override_json = local.principals_full_access_non_empty ? join("", data.aws_iam_policy_document.resource_full_access.*.json) : join("", data.aws_iam_policy_document.empty.*.json)
}


# Description : Provides an Elastic Container Registry Repository Policy.
resource "aws_ecr_repository_policy" "default" {
  count      = local.ecr_need_policy && var.enabled_ecr ? 1 : 0
  repository = join("", aws_ecr_repository.default.*.name)
  policy     = join("", data.aws_iam_policy_document.resource.*.json)
}


# module "ecr_docker_build" {
#   source             = "github.com/onnimonni/terraform-ecr-docker-build-module"
#   dockerfile_folder  = path.module
#   docker_image_tag   = "$(git log -1 --pretty=format:%h)"
#   aws_region         = var.aws_region
#   ecr_repository_url = aws_ecr_repository.default[0].repository_url
# }
