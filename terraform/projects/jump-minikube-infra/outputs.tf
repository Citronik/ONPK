output "router_IP" {
  value = openstack_networking_router_v2.op_router.external_fixed_ip[0].ip_address
}

output "instance_private_key" {
  value     = openstack_compute_keypair_v2.instance_keypair.private_key
  sensitive = true
}

output "instance_IP" {
  value = data.openstack_networking_floatingip_v2.floating_ip.address
}

output "public_instance_ip" {
  value = openstack_compute_instance_v2.public_instance.access_ip_v4
}