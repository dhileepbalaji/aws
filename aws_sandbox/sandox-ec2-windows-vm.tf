# get latest windows ami
data "aws_ami" "windows" {
     most_recent = true     
filter {
       name   = "name"
       values = ["Windows_Server-2016-English-Full-Base-*"]  
  }     
filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }     
owners = ["801119661308"] 
}
################################################################################
# Security Group
################################################################################

resource "aws_security_group" "sandox-ec2-windows-vm" {
    vpc_id = module.sandboxvpc.vpc_id
    name = "sandox-ec2-windows-vm"
    description = "security group that allows http, rdp and winrm and all egress traffic"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # rdp - Port 3389
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # WinRM - Port 5985 
    ingress {
        from_port = 5985
        to_port = 5985
        protocol = "tcp"
        cidr_blocks = module.sandboxvpc.vpc_cidr_block
    }

    # WinRM - Port 5986 
    ingress {
        from_port = 5986
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = module.sandboxvpc.vpc_cidr_block
    }  

    tags = var.tags
}


resource "aws_kms_key" "ec2" {
  description             = "KMS key is used to encrypt ebs volumes"
  deletion_window_in_days = 30
  is_enabled              = true
  tags                    = var.tags
}

################################################################################
# Ec2 Module
################################################################################
locals {
  instance_count   = 1
}
module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  instance_count = local.instance_count

  name                        = "sandbox-ec2"
  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.key_pair.key_name
  subnet_id                   = tolist(module.sandboxvpc.public_subnets)[0]
  vpc_security_group_ids      = [aws_security_group.sandox-ec2-windows-vm.id]
  associate_public_ip_address = true
  user_data = file("userdata.ps1")
  # applicable only for t2 and t3 series
  cpu_credits                 = "unlimited"
  tags = var.tags
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 50
      encrypted   = true
      kms_key_id  = aws_kms_key.ec2.arn
    }
  ]
}

resource "aws_volume_attachment" "d-drive" {
  count = local.instance_count

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.d-drive[count.index].id
  instance_id = module.ec2.id[count.index]
}

resource "aws_ebs_volume" "d-drive" {
  count = local.instance_count
  encrypted   = true
  type = "gp2"
  kms_key_id  = aws_kms_key.ec2.arn
  availability_zone = module.ec2.availability_zone[count.index]
  size              = 50
  tags  = var.tags
}

resource "aws_volume_attachment" "e-drive" {
  count = local.instance_count

  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.e-drive[count.index].id
  instance_id = module.ec2.id[count.index]
}

resource "aws_ebs_volume" "e-drive" {
  count = local.instance_count
  encrypted   = true
  type = "gp2"
  kms_key_id  = aws_kms_key.ec2.arn
  availability_zone = module.ec2.availability_zone[count.index]
  size              = 50
  tags  = var.tags
}