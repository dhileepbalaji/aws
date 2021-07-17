  
output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}
output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db.db_instance_endpoint
}
output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db.db_instance_username
  sensitive   = true
}
output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.db.db_instance_password
  sensitive   = true
}
output "db_instance_port" {
  description = "The database port"
  value       = module.db.db_instance_port
}

#Key Pair output
output "key_pair_key_name" {
  description = "The key pair name."
  value       = aws_key_pair.key_pair.key_name
}

output "private_key_pem" {
  description = "The private key used to connect to instances. Keep it in a secure place"
  value       = tls_private_key.this.private_key_pem
  sensitive = true

}

