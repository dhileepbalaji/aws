
# create sandbox key pair
resource "random_pet" "keypair" {
  length = 2
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = random_pet.keypair.id
  public_key = tls_private_key.this.public_key_openssh
  tags = var.tags
}

resource "local_file" "private_key" {
  sensitive_content         = tls_private_key.this.private_key_pem
  filename        = "ec2_keypair.pem"
  file_permission = "0600"
}

