
locals {
  bucket_name = "sandbox-bucket-${random_pet.s3.id}"
}

resource "random_pet" "s3" {
  length = 2
}


resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 30
  is_enabled              = true
  tags                    = var.tags
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}

module "s3_bucket_sandbox" {
  #https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest?tab=inputs
  source = "terraform-aws-modules/s3-bucket/aws"
  create_bucket = true                          # set to true to create this bucket
  bucket = local.bucket_name                    # bucket name

  versioning = {                                # enable or disable object versioning 
    enabled = true
  }
  server_side_encryption_configuration = {      # server side encryption for objects
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags  = var.tags                              # set tags

  attach_policy = true                          # allow this module to attach user policies
  attach_public_policy = true                   # Manages S3 bucket-level Public Access Block configuration

  # S3 bucket-level Public Access Block configuration
  block_public_acls = true                      # Amazon S3 should block public ACLs for this bucket
  block_public_policy = true                    # Amazon S3 should block public bucket policies for this bucket
  ignore_public_acls = true                     # Amazon S3 should ignore public ACLs for this bucket
  restrict_public_buckets = true                # Amazon S3 should restrict public bucket policies for this bucket.
  attach_deny_insecure_transport_policy = true  # attach only https traffic policy
  acl    = "private"                            # set bucket canned acl to private or public-read,public-read-write
}