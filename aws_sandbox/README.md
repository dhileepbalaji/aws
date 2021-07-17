# AWS Sandbox

This directory contains an AWS Sandbox Terraform module. Usage and details for this is detailed below.

The AWS account which needs to be configured as a sandbox must be created already and the owner must have access to it. The environment is set up with a bootstrap configuration consisting of the following -

1. Baseline network configuration - This consists of a VPC with a user specified CIDR and a security group with ingress limited to the VPC CIDR and a list of user supplied CIDRS and egress open to the internet 
2. Sandbox Owner                  - Owner IAM user for sandbox with full permissions, to be used for administration the sandbox 
3. Sandbox User                   - User IAM user for sandbox with restricted permissions to allow secure sandbox usage, to be used by sandbox users
4. S3 Public Access Block         - Blocks any public S3 bucket creation
5. IAM Password Policy            - Enforces PCI compliant password policy

## Architecture

The sandbox account is designed to allow the sandbox user to have maximum privileges while restricting creation of resources which could be accessed by anyone from the public internet.

The sandbox user has full access to IAM, EC2, S3 and many other services with restrictions in place to prevent creation of wide open security groups and public S3 buckets.

This is achieved by creating a permission boundary for the sandbox user as well as using the S3 block public access feature.

Note that the Elasticsearch service is restricted due to a lack of ability to restrict creation of public Elasticsearch instances.

## Usage

Prerequisite: A new AWS account must be created. The module must be created with the root user or organization account access role, depending on how the account was created.

This module requires the following variables:

1. sandbox_owner_name - The name of the role to be used by Sandbox owner
2. AWS_REGION         - The name of AWS region to create resources
3. sandbox_user_name - The name of the role to be used by Sandbox users
4. inbound_vpn_cidr - The CIDR block to be used to allow inbound access from specific IPs to the sandbox security group (this is generally a trusted IP you want to allow connections from)
5. vpc_cidr - The CIDR block used for the sandbox VPC
6. public_subnets - List of public subnets need to be created
7. private_subnets -List of private subnets need to be created

```
module "aws_sandbox" {
  source                        = "./aws_sandbox"
  AWS_REGION                    = "<AWS region to create resources>"
  sandbox_user_name             = "<Sandbox User role name>"
  sandbox_Owner_name            = "<Sandbox Owner role name>"
  inbound_vpn_cidr              = ["<List of CIDRs>"]
  vpc_cidr                      = "CIDR for VPC"
  public_subnets                = "[{<map of subnets to create>}]"
  private_subnets               = "[{<map of subnets to create>}]"
}
```

## Example

Given below is an example implementation.

The implementation sets up the bootstrap configuration for an example AWS sandbox environment.

```
module "sandbox" {
  source             				      = "./aws_sandbox"
  AWS_REGION                      = "eu-central-1"
  sandbox_owner_name              = "Sandbox-Owner"
  sandbox_user_name               = "Sandbox-User"
  inbound_vpn_cidr				        = ["1.2.3.4/32"]
  vpc_cidr                        = "10.0.0.0/16"
  public_subnets                  = [{
                                    Name="PublicSubnet1",cidr_block="10.0.0.0/24",availability_zone="eu-central-1a"
                                    }]
  private_subnets                  = [{
                                    Name="PrivateSubnet1",cidr_block="10.0.1.0/24",availability_zone="eu-central-1b"
                                    }]
}
```

An example main.tf file is also present in the repository for purposes of testing out module usage.

## Configuring AWS Creds for Terraform

We need to run below commands in linux machines to provide AWS creds for terraform.

```
export AWS_ACCESS_KEY_ID="<accesskey>"
export AWS_SECRET_ACCESS_KEY="<secretkey>"
export AWS_DEFAULT_REGION="<region>"
terraform plan
```

We need to run below commands in Windows machines(Powershell) to provide AWS creds for terraform.

```
$Env:AWS_ACCESS_KEY_ID="<accesskey>"
$Env:AWS_SECRET_ACCESS_KEY="<secretkey>"
$Env:AWS_DEFAULT_REGION="<region>"
```