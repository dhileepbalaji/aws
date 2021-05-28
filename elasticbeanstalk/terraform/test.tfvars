vpc_id = "vpc-20f74844"
allocated_storage = "32"
engine_version = "13.2"
instance_type = "db.t3.micro"
storage_type = "gp2"
database_identifier = "t12jky32t3st"
database_name = "testdb"
database_username = "testuser"
database_password = "testuser123"
database_port = "5432"
backup_retention_period = "30"
backup_window = "04:00-04:30"
maintenance_window = "sun:04:30-sun:05:30"
auto_minor_version_upgrade = false
multi_availability_zone = false
storage_encrypted = false
deletion_protection = true
cloudwatch_logs_exports = ["postgresql"]
project = "test"
environment = "Staging"