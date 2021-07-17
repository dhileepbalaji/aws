variable "sandbox_owner_name" {}
variable "sandbox_user_name" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    enviroment = "sandbox"
  }
}


variable "aws_allowed_regions" {
  type = list(string)
  default = ["eu-west-1"]
}

variable "sandbox_user_role_name" {
  type = string
  default = "sandbox_user_role"
}

variable "sandbox_owner_role_name" {
  type = string
  default = "sandbox_owner_role"
}

variable "sandbox_owner_group" {
  type = list(string)
  default = [""]
}

variable "sandbox_user_group" {
  type = list(string)
  default = [""]
}