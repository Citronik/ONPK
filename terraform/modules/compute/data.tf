data "openstack_networking_subnet_v2" "subnet_existing" {
  name = openstack_networking_subnet_v2.subnet.name
}

data "openstack_networking_network_v2" "private_network" {
  name = openstack_networking_network_v2.network_main.name
}

data "openstack_compute_flavor_v2" "flavor" {
  name = local.kis.instance.flavor_name
}

data "openstack_images_image_v2" "image" {
  name = local.kis.instance.image.ubuntu.name
}

data "openstack_compute_flavor_v2" "flavor_mini" {
  name = local.kis.instance.flavor_mini_name
}

data "openstack_images_image_v2" "image_debian" {
  name = local.kis.instance.image.debian.name
}

data "openstack_networking_network_v2" "public_network" {
  name = var.public_network_name
}
