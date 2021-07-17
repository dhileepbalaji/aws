resource "aws_iam_group" "sandbox_user" {
  name = "sandbox_user"
  path = "/sandbox/"
  
}

resource "aws_iam_user" "sandbox_user" {
  count = length(var.sandbox_user_name) > 0 ? length(var.sandbox_user_name) : 0
  path = "/sandbox/"
  name = var.sandbox_user_name[count.index]
  permissions_boundary = aws_iam_policy.sandbox_user_permissions_boundary.arn
  tags = var.tags
  force_destroy = true
  
}

resource "aws_iam_user_group_membership" "sandbox_user" {
  count =    length(aws_iam_user.sandbox_user.*.name) > 0 ? length(aws_iam_user.sandbox_user.*.name) : 0
  user  =     aws_iam_user.sandbox_user[count.index].name
  
  groups = [
    aws_iam_group.sandbox_user.name,
  ]
}

resource "aws_iam_user_group_membership" "sandbox_existing_user" {
  count =    length(var.sandbox_user_group) > 0 ? length(var.sandbox_user_group) : 0
  user  =     var.sandbox_user_group[count.index]
  
  groups = [
    aws_iam_group.sandbox_user.name,
  ]
}

resource "aws_iam_policy" "sandbox_user_policy" {
  name        = "sandbox_user_policy"
  description = "Policy for Sandbox user"
  policy      = local.sandbox_user_policy
  tags = var.tags
}

resource "aws_iam_policy" "sandbox_user_permissions_boundary" {
  name        = "sandbox_user_permissions_boundary"
  description = "Permission boundary for Sandbox user"
  policy      = local.sandbox_user_perms_boundary
  tags = var.tags
}

data "aws_iam_policy_document" "sandbox_user_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

  }
}

resource "aws_iam_role" "sandbox_user" {
  name               = var.sandbox_user_role_name
  path               = "/sandbox/"
  assume_role_policy = data.aws_iam_policy_document.sandbox_user_assume_role_policy.json
  permissions_boundary = aws_iam_policy.sandbox_user_permissions_boundary.arn
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sandbox_user_policy_attachment" {
  role       = aws_iam_role.sandbox_user.name
  policy_arn = aws_iam_policy.sandbox_user_policy.arn
}


data "aws_iam_policy_document" "sandbox_user_assume_role_group_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.sandbox_user.arn
    ]
  }
}

resource "aws_iam_policy" "sandbox_user_group_policy" {
  name        = "sandbox_user_group_policy"
  description = "Policy for Sandbox group"
  policy      = data.aws_iam_policy_document.sandbox_user_assume_role_group_permissions.json
  tags = var.tags
}
resource "aws_iam_group_policy_attachment" "sandbox_user_policy_attachment" {
  group       = aws_iam_group.sandbox_user.name
  policy_arn = aws_iam_policy.sandbox_user_policy.arn
}