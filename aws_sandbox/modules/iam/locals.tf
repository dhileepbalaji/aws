 data "aws_caller_identity" "current" {}

 
 locals {
   account_id = data.aws_caller_identity.current.account_id
   
   sandbox_owner_policy = templatefile("${path.module}/templates/sandbox_owner_policy.json.tpl", {
     allowed_regions = var.aws_allowed_regions
  })

   sandbox_user_policy = templatefile("${path.module}/templates/sandbox_user_policy.json.tpl", {
     allowed_regions = var.aws_allowed_regions
  })

   sandbox_user_perms_boundary = templatefile("${path.module}/templates/sandbox_user_perms_boundary.json.tpl", {
     allowed_regions = var.aws_allowed_regions
   })

 }

 