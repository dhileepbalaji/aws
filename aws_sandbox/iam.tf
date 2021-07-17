module "sandbox_vpc_iam" {
  source             				      = "./modules/iam"
  # Only in below regions sandbox users can create resources
  aws_allowed_regions             = ["eu-central-1","eu-west-1"]
  # Creating new user with owner access
  sandbox_owner_name              = ["Sandbox-Owner"]
  # Creating new user with user access
  sandbox_user_name               = ["Sandbox-User"]
  # add existing user to sandbox_owner_group
  sandbox_owner_group             = []
  # add existing user to sandbox_user_group
  sandbox_user_group              = []

  tags                              = var.tags
}
