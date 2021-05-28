
# key pair
resource "aws_key_pair" "eb" {
  key_name = "testuser" 
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAvg9SsLFTy56mcOwNqkco0iP7OY0/sRiyrjabzhy5YyK+6b9mJ3DSwU0p1knowPs4GsX+/lf/5/orrUeFO+WJ05gct4rhTpZaVBT9nw4sZKlfOLlg4tlA0zN+3ZeMGaBAIlvgYwJaAqj7NdXrP8IXdWpgC8V+r0BgSJ7zuyFm8sexfGzJKFIlyp3LwAoQI2z4RgdMSj9/Uiz1s83Kk02dT4ue+8oxTYsY0vpe71GMgnXOpZy1kpMWBAX6aOF0e6YF9Z73zWK8ZqF0VdlouGRzVShVZJ+uTt7my/MWyLJfplq9bMdBPh7G1T3RSGiFwcHYUl9CdUJbSSw6OK4BQyy1oQ== testuser"
}

# sec group
resource "aws_security_group" "eb" {
  vpc_id = aws_vpc.main.id
  name = "eb-prod"
  description = "eb prod security group"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eb-prod"
  }
}

# eb

resource "aws_elastic_beanstalk_application" "eb" {
  name = "eb"
  description = "eb"
}
resource "aws_elastic_beanstalk_environment" "eb-prod" {
  name = "eb-prod"
  application = aws_elastic_beanstalk_application.eb.name
  solution_stack_name = "64bit Amazon Linux 2 v5.3.2 running Node.js 14"
  cname_prefix = "eb-prod-a2b6d0"
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.main.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = aws_subnet.private-1.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "eb-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = aws_security_group.eb.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = aws_key_pair.eb.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = aws_subnet.public-1.id
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_USERNAME"
    value = aws_db_instance.postgresql.username
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = aws_db_instance.postgresql.password
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_DATABASE"
    value = aws_db_instance.postgresql.name
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_HOSTNAME"
    value = element(split(":", aws_db_instance.postgresql.endpoint),0)
  }

  depends_on = [aws_vpc.main,aws_security_group.eb,aws_db_instance.postgresql]
}
