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
  image                      = local.kis.instance.image.ubuntu.name
  flavor                     = local.kis.instance.flavor_name
}

resource "null_resource" "wait_for_minikube" {
  triggers = {
    instance_id = module.instance.private_instance_id
  }

  provisioner "local-exec" {
    command = <<EOF
      set SSH_KEY_JUMP="${path.module}/${openstack_compute_keypair_v2.public_kp.name}.pem"
      set SSH_KEY_PRIVATE="${path.module}/${openstack_compute_keypair_v2.private_kp.name}.pem"

      set PUBLIC_INSTANCE_IP="${module.instance.public_instance_ip}"
      set PRIVATE_INSTANCE_IP="${module.instance.private_instance_ip}"

      set USERNAME="${local.kis.instance.image.ubuntu.username}"

      ssh -i "%SSH_KEY_JUMP%" -L 8080:%PRIVATE_INSTANCE_IP%:22 %USERNAME%@%PUBLIC_INSTANCE_IP% -N &

      until ssh -i "%SSH_KEY_JUMP%" -p 8080 localhost "docker --version & > /dev/null"; do
        echo "Waiting for Docker installation to complete..."
        sleep 5
      done

      until ssh -i "%SSH_KEY_JUMP%" -p 8080 localhost "minikube version &> /dev/null"; do
        echo "Waiting for Minikube installation to complete..."
        sleep 5
      done

      until ssh -i "%SSH_KEY_JUMP%" -p 8080 localhost "minikube status &> /dev/null"; do
        echo "Waiting for Minikube to be ready..."
        sleep 5
      done

      until ssh -i "$SSH_KEY_JUMP" -p 8080 localhost "kubectl get nodes | grep -q ' Ready '"; do
        echo "Waiting for Kubernetes components to be ready..."
        sleep 5
      done
    EOF
  }
}