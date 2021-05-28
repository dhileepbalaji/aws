resource "aws_db_subnet_group" "rds-eb" {
    name = "rds-app-prod"
    description = "RDS subnet group"
    subnet_ids = [aws_subnet.private-1.id, aws_subnet.private-2.id]
}

# Security group resources
#
resource "aws_security_group" "postgresql" {
  vpc_id = aws_vpc.main.id
  ingress {
    description      = "RDS connection from anywhere"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = merge(
    {
      Name        = "sgDatabaseServer",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

#
# RDS resources
#
resource "aws_db_instance" "postgresql" {
  allocated_storage               = var.allocated_storage
  engine                          = "postgres"
  engine_version                  = var.engine_version
  identifier                      = var.database_identifier
  snapshot_identifier             = var.snapshot_identifier
  instance_class                  = var.instance_type
  storage_type                    = var.storage_type
  iops                            = var.iops
  name                            = var.database_name
  password                        = var.database_password
  username                        = var.database_username
  publicly_accessible             = var.publicly_accessible
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  maintenance_window              = var.maintenance_window
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  final_snapshot_identifier       = var.final_snapshot_identifier
  skip_final_snapshot             = var.skip_final_snapshot
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  multi_az                        = var.multi_availability_zone
  port                            = var.database_port
  vpc_security_group_ids          = [aws_security_group.postgresql.id]
  db_subnet_group_name            = aws_db_subnet_group.rds-eb.name
  parameter_group_name            = var.parameter_group
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports

  tags = merge(
    {
      Name        = "DatabaseServer",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}



resource "null_resource" "initial_setup" {

  # runs after database and security group providing external access is created
  depends_on = [aws_db_instance.postgresql, aws_security_group.postgresql]

    provisioner "local-exec" {
        command = "psql -h \"${aws_db_instance.postgresql.address}\" -p 5432 -U \"${aws_db_instance.postgresql.username}\" -d \"${aws_db_instance.postgresql.name}\" -f \"../src/testdb.sql\""
        environment = {
          # for instance, postgres would need the password here:
          PGPASSWORD = aws_db_instance.postgresql.password
        }
    }
}