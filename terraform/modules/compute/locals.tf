locals {
  # Compute
  kis = {
    network = {
      cidr = "158.193.0.0/16"
    },
    instance = {
      flavor_name      = "2c2r20d",
      flavor_mini_name = "1c05r8d",
      image = {
        ubuntu = {
          name = "ubuntu-22.04-KIS"
        },
        debian = {
          name = "debian-12-kis"
        }
      }
    }
  }
}