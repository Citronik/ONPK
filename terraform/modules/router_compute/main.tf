# --- main.tf ---
resource "openstack_networking_network_v2" "network_main" {
  name           = "${var.project}-${var.environment}-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${var.project}-${var.environment}-subnet"
  network_id = openstack_networking_network_v2.network_main.id
  cidr       = var.private_cidr
}

data "openstack_networking_network_v2" "public_network" {
  name = var.public_network_name
}

resource "openstack_networking_router_v2" "op_router" {
  name                = "${var.project}-${var.environment}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.op_router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_networking_secgroup_v2" "security_group_onpk" {
  name        = "${var.project}-${var.environment}-secgroup"
  description = "${var.project} mannaged by terraform "
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_kis_icmp" {
  description       = "Managed by Terraform!"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = local.kis.network.cidr
  security_group_id = openstack_networking_secgroup_v2.security_group_onpk.id
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_kis_ssh" {
  description       = "Managed by Terraform!"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.kis.network.cidr
  security_group_id = openstack_networking_secgroup_v2.security_group_onpk.id
}

resource "openstack_compute_keypair_v2" "instance_keypair" {
  name = "${var.project}-${var.environment}-keypair"
}

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "${var.project}-${var.environment}-instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = data.openstack_compute_keypair_v2.kp.name
  security_groups = [openstack_networking_secgroup_v2.security_group_onpk.id]

  metadata = {
  }

  network {
    name = data.openstack_networking_network_v2.private_network.name
  }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = var.public_network_name
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.instance_1.id
}

##########################################################################################