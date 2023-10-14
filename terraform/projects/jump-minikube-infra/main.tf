resource "openstack_compute_keypair_v2" "private_kp" {
  name = "${var.project}-${var.environment}-private_kp"
}

resource "local_file" "private_key-private_kp" {
  content         = openstack_compute_keypair_v2.private_kp.private_key
  filename        = "${path.module}/${openstack_compute_keypair_v2.private_kp.name}.pem"
  file_permission = "0400"
}

resource "openstack_compute_keypair_v2" "public_kp" {
  name = "${var.project}-${var.environment}-private_kp"
}

resource "local_file" "private_key-public_kp" {
  content         = openstack_compute_keypair_v2.public_kp.private_key
  filename        = "${path.module}/${openstack_compute_keypair_v2.public_kp.name}.pem"
  file_permission = "0400"
}

module "instance" {
  source        = "terraform/modules/compute"
  project       = local.project
  environment   = var.environment
  my_public_ip  = data.http.my_public_ip.response_body
  key_pair_name = openstack_compute_keypair_v2.keypair.name
  flavor_name   = var.flavor_name
  user_data     = data.cloudinit_config.user_data.rendered
}