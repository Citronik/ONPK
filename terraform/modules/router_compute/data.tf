data "openstack_networking_router_v2" "router_existing" {
  name = openstack_networking_router_v2.op_router.name
}

data "openstack_networking_subnet_v2" "subnet_existing" {
  name = openstack_networking_subnet_v2.subnet.name
}

data "openstack_networking_network_v2" "private_network" {
  name = openstack_networking_network_v2.network_main.name
}
# 
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor
}

data "openstack_images_image_v2" "image" {
  name = var.image
}

data "openstack_networking_floatingip_v2" "floating_ip" {
  address = openstack_networking_floatingip_v2.fip_1.address
}