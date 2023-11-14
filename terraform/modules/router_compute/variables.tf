# --- variables.tf ---

# Default: ext-net-154 (public network -> instance is connected to the public internet)
variable "public_network_name" {
  type = string
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

variable "public_instance-kp" {
  type = string
}

variable "private_instance-kp" {
  type = string
}

variable "user_data_private_instance" {
  type = string
}

variable "user_data_public_instance" {
  type = string
}

variable "image" {
  type = string
}

variable "flavor" {
  type = string
}