variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    enviroment        = "sandbox",
    deploy_type       = "terraform"
  }
}

variable "AWS_REGION" {
  type = string
  default = "eu-central-1"
}