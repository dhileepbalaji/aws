locals {
  rds_name   = "sandbox-mssql"
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = local.rds_name
  description = "Complete SqlServer  security group"
  vpc_id      = module.sandboxvpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "SqlServer access from within VPC"
      cidr_blocks = module.sandboxvpc.vpc_cidr_block
    },
  ]

  tags = var.tags
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.rds_name

  engine               = "sqlserver-web"
  engine_version       = "14.00.3049.1.v1"
  family               = "sqlserver-web-14.0" # DB parameter group
  major_engine_version = "14.00"             # DB option group
  instance_class       = "db.m5.large"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  name                   = null # DBName must be null for engine: sqlserver-ex
  username               = "sandboxdbuser"
  create_random_password = true
  random_password_length = 12
  port                   = 1433
  # Only enable the below options if you want db to be part of Active Directory
  #domain               = aws_directory_service_directory.demo.id
  #domain_iam_role_name = aws_iam_role.rds_ad_auth.name

  multi_az               = false
  subnet_ids             = module.sandboxvpc.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = false
  monitoring_interval                   = 0

  options                   = []
  create_db_parameter_group = false
  license_model             = "license-included"
  timezone                  = "GMT Standard Time"
  character_set_name        = "Latin1_General_CI_AS"

  tags = var.tags
}