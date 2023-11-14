output "router_IP" {
  value = openstack_networking_router_v2.op_router.external_fixed_ip[0].ip_address
}

# output "instance_private_key" {
#   value     = openstack_compute_keypair_v2.instance_keypair.private_key
#   sensitive = true
# }

output "public_instance_ip" {
  value = data.openstack_networking_floatingip_v2.floating_ip.address
}

output "private_instance_ip" {
  value = openstack_compute_instance_v2.private_instance.access_ip_v4
}

output "private_instance_id" {
  value = openstack_compute_instance_v2.private_instance.id  
}