terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}

provider "aws" {
   region = "ap-southeast-1"
}