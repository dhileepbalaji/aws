resource "aws_iam_group" "sandbox_owner" {
  name = "sandbox_owner"
  path = "/sandbox/"
}


resource "aws_iam_user" "sandbox_owner" {
  count = length(var.sandbox_owner_name) > 0 ? length(var.sandbox_owner_name) : 0
  path = "/sandbox/"
  name = var.sandbox_owner_name[count.index]
  tags = var.tags
  force_destroy = true
}

resource "aws_iam_user_group_membership" "sandbox_owner" {
  count =    length(aws_iam_user.sandbox_owner.*.name) > 0 ? length(aws_iam_user.sandbox_owner.*.name) : 0
  user  =    aws_iam_user.sandbox_owner[count.index].name

  groups = [
    aws_iam_group.sandbox_owner.name,
  ]
}


resource "aws_iam_user_group_membership" "sandbox_existing_owner" {
  count =    length(var.sandbox_owner_group) > 0 ? length(var.sandbox_owner_group) : 0
  user  =     var.sandbox_owner_group[count.index]
  
  groups = [
    aws_iam_group.sandbox_owner.name,
  ]
}


resource "aws_iam_policy" "sandbox_owner_policy" {
  name        = "sandbox_owner_policy"
  description = "Policy for Sandbox owner"
  policy      = local.sandbox_owner_policy
  tags = var.tags
}


data "aws_iam_policy_document" "sandbox_owner_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

  }
}

resource "aws_iam_role" "sandbox_owner" {
  name               = var.sandbox_owner_role_name
  path               = "/sandbox/"
  assume_role_policy = data.aws_iam_policy_document.sandbox_owner_assume_role_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sandbox_owner_policy_attachment" {
  role       = aws_iam_role.sandbox_owner.name
  policy_arn = aws_iam_policy.sandbox_owner_policy.arn
}
# We can't assign IAM role to IAM user or group, see the notes from this AWS official doc https://aws.amazon.com/iam/faqs/
data "aws_iam_policy_document" "sandbox_owner_assume_role_group_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.sandbox_owner.arn
    ]
  }
}

resource "aws_iam_policy" "sandbox_owner_group_policy" {
  name        = "sandbox_owner_group_policy"
  description = "Policy for Sandbox group"
  policy      = data.aws_iam_policy_document.sandbox_owner_assume_role_group_permissions.json
  tags = var.tags
}
resource "aws_iam_group_policy_attachment" "sandbox_owner_policy_attachment" {
  group       = aws_iam_group.sandbox_owner.name
  policy_arn = aws_iam_policy.sandbox_owner_policy.arn
}