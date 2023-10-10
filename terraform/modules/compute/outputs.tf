#output "router_IP" {
#  value = openstack_networking_router_v2.op_router.external_fixed_ip[0].ip_address
#}

output "private_instance_key" {
  value     = openstack_compute_keypair_v2.private_instance_keypair.private_key
  sensitive = true
}
