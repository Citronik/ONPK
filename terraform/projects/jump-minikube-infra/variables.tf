# --- variables.tf ---

variable "username" {
  type = string
}
variable "tenant_name" {
  type = string
}

variable "password" {
  type = string
}

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