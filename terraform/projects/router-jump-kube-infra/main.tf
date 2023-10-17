data "cloudinit_config" "user_data_1" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_update"
    content      = file("/scripts/updating.sh")
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_docker"
    content      = file("/scripts/docker.sh")
  }
  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_minikube"
    content      = file("/scripts/minikube.sh")
  }
}

data "cloudinit_config" "user_data_2" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_update"
    content      = file("/scripts/updating.sh")
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_fwd"
    content      = file("/scripts/ip_forwarding.sh")
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_port_fwd"
    content      = file("/scripts/port_forwarding.sh")
  }

}

# resource "local_file" "public_key-private_kp" {
#   filename        = "${path.module}/${var.project}-${var.environment}-private_kp-public.pem"
# }

resource "openstack_compute_keypair_v2" "private_kp" {
  name       = "${var.project}-${var.environment}-private_kp"
  public_key = var.public_key-private_kp
}

# resource "local_file" "public_key-public_kp" {
#   filename        = "${path.module}/${var.project}-${var.environment}-public_kp-public.pem"
# }

resource "openstack_compute_keypair_v2" "public_kp" {
  name       = "${var.project}-${var.environment}-public_kp"
  public_key = var.public_key-public_kp
}

module "instance" {
  #source        = "github.com/Citronik/ONPK/tree/main/terraform/modules/compute"
  #source = "github.com/Citronik/ONPK/terraform/modules/compute"
  source                     = "../../modules/router_compute"
  project                    = var.project
  environment                = var.environment
  public_network_name        = var.public_network_name
  private_cidr               = var.private_cidr
  private_instance-kp        = openstack_compute_keypair_v2.private_kp.name
  public_instance-kp         = openstack_compute_keypair_v2.public_kp.name
  user_data_private_instance = data.cloudinit_config.user_data_1.rendered
  user_data_public_instance  = data.cloudinit_config.user_data_2.rendered
}

# resource "null_resource" "wait_for_minikube" {
#   triggers = {
#     instance_id = module.instance.instance_ids[0]  # Assuming you're using an output from your module to get the instance ID
#   }
# 
#   provisioner "local-exec" {
#     command = <<EOF
#       SSH_KEY="${path.module}/${openstack_compute_keypair_v2.public_kp.name}.pem"
# 
#       PUBLIC_INSTANCE_IP="${module.instance.public_ips[0]}"
#       INSTANCE_IP="${module.instance.private_ips[0]}"
# 
#       # Establish an SSH tunnel to the private instance through the public instance
#       ssh -i "$SSH_KEY" -L 8080:$PRIVATE_INSTANCE_IP:22 ${local.kis.instance.image.ubuntu.username}@$PUBLIC_INSTANCE_IP -N &
# 
# 
#       until ssh -i "$SSH_KEY" -p 8080 localhost "minikube status &> /dev/null"; do
#         echo "Waiting for Minikube to be ready..."
#         sleep 10
#       done
# 
#       # Check if Kubernetes components are ready (you may need to adjust this based on your specific case)
#       until ssh -i "$SSH_KEY" -p 8080 localhost "kubectl get nodes | grep -q ' Ready '"; do
#         echo "Waiting for Kubernetes components to be ready..."
#         sleep 10
#       done
#     EOF
#   }
# }