variable "project" {
  default     = "Unknown"
  type        = string
  description = "Name of project this VPC is meant to house"
}

variable "environment" {
  default     = "Unknown"
  type        = string
  description = "Name of environment this VPC is targeting"
}

variable "allocated_storage" {
  default     = 32
  type        = number
  description = "Storage allocated to database instance"
}

variable "engine_version" {
  default     = "11.5"
  type        = string
  description = "Database engine version"
}

variable "instance_type" {
  default     = "db.t3.micro"
  type        = string
  description = "Instance type for database instance"
}

variable "storage_type" {
  default     = "gp2"
  type        = string
  description = "Type of underlying storage for database"
}

variable "iops" {
  default     = 0
  type        = number
  description = "The amount of provisioned IOPS"
}

variable "database_identifier" {
  type        = string
  description = "Identifier for RDS instance"
}

variable "snapshot_identifier" {
  default     = ""
  type        = string
  description = "The name of the snapshot (if any) the database should be created from"
}

variable "database_name" {
  type        = string
  description = "Name of database inside storage engine"
}

variable "database_username" {
  type        = string
  description = "Name of user inside storage engine"
}

variable "database_password" {
  type        = string
  description = "Database password inside storage engine"
}

variable "database_port" {
  default     = 5432
  type        = number
  description = "Port on which database will accept connections"
}

variable "backup_retention_period" {
  default     = 30
  type        = number
  description = "Number of days to keep database backups"
}

variable "backup_window" {
  # 12:00AM-12:30AM ET
  default     = "04:00-04:30"
  type        = string
  description = "30 minute time window to reserve for backups"
}

variable "maintenance_window" {
  # SUN 12:30AM-01:30AM ET
  default     = "sun:04:30-sun:05:30"
  type        = string
  description = "60 minute time window to reserve for maintenance"
}

variable "auto_minor_version_upgrade" {
  default     = true
  type        = bool
  description = "Minor engine upgrades are applied automatically to the DB instance during the maintenance window"
}

variable "final_snapshot_identifier" {
  default     = "terraform-aws-postgresql-rds-snapshot"
  type        = string
  description = "Identifier for final snapshot if skip_final_snapshot is set to false"
}

variable "skip_final_snapshot" {
  default     = true
  type        = bool
  description = "Flag to enable or disable a snapshot if the database instance is terminated"
}

variable "copy_tags_to_snapshot" {
  default     = false
  type        = bool
  description = "Flag to enable or disable copying instance tags to the final snapshot"
}

variable "multi_availability_zone" {
  default     = false
  type        = bool
  description = "Flag to enable hot standby in another availability zone"
}

variable "storage_encrypted" {
  default     = false
  type        = bool
  description = "Flag to enable storage encryption"
}

variable "deletion_protection" {
  default     = false
  type        = bool
  description = "Flag to protect the database instance from deletion"
}

variable "cloudwatch_logs_exports" {
  default     = ["postgresql", "upgrade"]
  type        = list
  description = "List of logs to publish to CloudWatch Logs"
}


variable "publicly_accessible" {
  default     = false
}

variable "parameter_group" {
  default     = "default.postgres13"
  type        = string
  description = "Database engine parameter group"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the RDS resources"
}
