variable "domain_name" {
  description = "the domain name of your site"
}

variable "zone_id" {
  description = "the zone_id in route 53"
}

variable "aws_region" {
  description = "the aws region"
}

variable "instance_type" {
  description = "the aws instance type"
}

variable "key_name" {
  description = "key name"
}

variable "log_group_name" {
  description = "the log group name"
}

variable "log_retention_days" {
  description = "log retention days"
}
