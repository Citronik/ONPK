# --- variables.tf ---

# Default: ext-net-154 (public network -> instance is connected to the public internet)
variable "public_network_name" {
  type    = string
  default = "ext-net-154"
}

variable "private_cidr" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "user_data_1" {
  type = string
}

variable "user_data_2" {
  type = string
}

variable "public_kp" {
  type = string
}

variable "private_kp" {
  type = string
}