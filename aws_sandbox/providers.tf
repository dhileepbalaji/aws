terraform {
  required_version = "~> 1.0.0"  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.36"
    }
  }
}


#Configure the AWS Provider
provider "aws" {
  region = var.AWS_REGION
}