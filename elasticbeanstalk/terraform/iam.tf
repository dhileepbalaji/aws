# iam roles
resource "aws_iam_role" "eb-ec2-role" {
    name = "eb-ec2-role"
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
}
resource "aws_iam_instance_profile" "eb-ec2-role" {
    name = "eb-ec2-role"
    role = aws_iam_role.eb-ec2-role.name
}

# service
resource "aws_iam_role" "elasticbeanstalk-service-role" {
    name = "elasticbeanstalk-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# policies
resource "aws_iam_policy_attachment" "eb-attach1" {
    name = "eb-attach1"
    roles = [aws_iam_role.eb-ec2-role.name]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_policy_attachment" "eb-attach2" {
    name = "eb-attach2"
    roles = [aws_iam_role.eb-ec2-role.name]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}
resource "aws_iam_policy_attachment" "eb-attach3" {
    name = "eb-attach3"
    roles = [aws_iam_role.elasticbeanstalk-service-role.name]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}