output "project_name" {
  value = var.project
}

output "private_instance_name" {
  value = openstack_compute_instance_v2.private_instance.name
}

output "public_instance_name" {
  value = openstack_compute_instance_v2.public_instance.name
}

output "private_instance_ipv4_address" {
  value = openstack_compute_instance_v2.private_instance.access_ip_v4
}

output "public_instance_ipv4_address" {
  value = openstack_compute_instance_v2.public_instance.access_ip_v4
}

output "instance_network_name" {
  value = data.openstack_networking_network_v2.private_network.name
}

output "instance_security_group_id" {
  value = openstack_compute_secgroup_v2.security_group_onpk_public.id
}

output "user_data_logs_path" {
  value = "/var/log/cloud-init-output.log"
}

output "ssh_command" {
  value = "ssh -i ${abspath(".")}/${var.key_pair_name}.pem ${local.image.ubuntu.os_username}@${openstack_compute_instance_v2.instance.access_ip_v4}"
}
output "private_instance_key" {
  value     = openstack_compute_keypair_v2.private_instance_keypair.private_key
  sensitive = true
}
