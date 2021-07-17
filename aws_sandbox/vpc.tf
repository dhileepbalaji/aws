locals {
  vpc_name   = "sandbox-vpc" # name of vpc and subnets
  region =  var.AWS_REGION  # region to create subnets
  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_block  = "0.0.0.0/0"
      },
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound = []
    public_outbound = []
    private_inbound = []
    private_outbound = []
  }
}

################################################################################
# VPC Module
################################################################################

module "sandboxvpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "10.1.0.0/16" # vpc cidr 

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = ["10.1.0.0/24"]
  public_subnets      = ["10.1.1.0/24"]
  database_subnets    = ["10.1.2.0/24","10.1.3.0/24"]

  create_database_subnet_group = true
  create_database_subnet_route_table = false
  # manage default route table
  manage_default_route_table = true
  default_route_table_routes = []
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true
  # use single nat gateway across AZ
  enable_nat_gateway = true
  single_nat_gateway = true

 
  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []
  # Define network acls
  public_dedicated_network_acl   = true
  public_inbound_acl_rules       = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  public_outbound_acl_rules      = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])
  private_dedicated_network_acl  = true
  private_inbound_acl_rules       = concat(local.network_acls["default_inbound"], local.network_acls["private_inbound"])
  private_outbound_acl_rules      = concat(local.network_acls["default_outbound"], local.network_acls["private_inbound"])

  tags = var.tags
}

################################################################################
# VPC Endpoints Module
################################################################################

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  create = true
  vpc_id             = module.sandboxvpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
  }

  tags = merge(var.tags, {
    Endpoint = "true"
  })
}


################################################################################
# Supporting Resources
################################################################################

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.sandboxvpc.vpc_id
}


