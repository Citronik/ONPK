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

resource "openstack_networking_secgroup_v2" "security_group_onpk_private" {
  name        = "${var.project}-${var.environment}-secgroup-private"
  description = "${var.project} mannaged by terraform "
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_kis_icmp" {
  depends_on        = [openstack_compute_instance_v2.public_instance]
  description       = "Managed by Terraform!"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.private_cidr
  security_group_id = openstack_networking_secgroup_v2.security_group_onpk_private.id
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_kis_ssh" {
  depends_on        = [openstack_compute_instance_v2.public_instance]
  description       = "Managed by Terraform!"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.private_cidr
  security_group_id = openstack_networking_secgroup_v2.security_group_onpk_private.id
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_kis_http" {
  depends_on        = [openstack_compute_instance_v2.public_instance]
  description       = "Managed by Terraform!"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.private_cidr
  security_group_id = openstack_networking_secgroup_v2.security_group_onpk_private.id
}

resource "openstack_compute_secgroup_v2" "security_group_onpk_public" {
  name        = "${var.project}-${var.environment}-secgroup-public"
  description = "${var.project}-${var.environment} mannaged by terraform"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = local.kis.network.cidr
  }
  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = local.kis.network.cidr
  }
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = local.kis.network.cidr
  }
  rule {
    ip_protocol = "icmp"
    from_port   = -1
    to_port     = -1
    cidr        = local.kis.network.cidr
  }
}

resource "openstack_compute_instance_v2" "private_instance" {
  depends_on      = [openstack_networking_secgroup_v2.security_group_onpk_private, openstack_compute_instance_v2.public_instance]
  name            = "${var.project}-${var.environment}-private_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.private_kp
  security_groups = [openstack_networking_secgroup_v2.security_group_onpk_private.id]

  user_data = var.user_data_1

  network {
    name = data.openstack_networking_network_v2.private_network.name
  }
}

resource "openstack_compute_instance_v2" "public_instance" {
  name            = "${var.project}-${var.environment}-public_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.public_kp
  security_groups = [openstack_compute_secgroup_v2.security_group_onpk_public.id]

  user_data = var.user_data_2

  network {
    name = data.openstack_networking_network_v2.public_network.name
  }
}

resource "openstack_compute_interface_attach_v2" "ai_1" {
  instance_id = openstack_compute_instance_v2.public_instance.id
  network_id  = data.openstack_networking_network_v2.private_network.id
}