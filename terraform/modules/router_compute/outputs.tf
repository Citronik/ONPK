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
