packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }

    azure = {
          source  = "github.com/hashicorp/azure"
          version = "~> 2"
    }

    digitalocean = {
          version = ">= 1.0.4"
          source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "nocodb-ubuntu-22.04"
  instance_type = "t2.micro"
  region = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "azure-arm" "ubuntu" {
  client_id                         = var.arm_client_id
  client_secret                     = var.arm_client_secret
  subscription_id                   = var.arm_subscription_id

  os_type         = "Linux"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_publisher = "Canonical"
  image_sku       = "22_04-lts"

  managed_image_resource_group_name = var.azure_resource_group
}

source "digitalocean" "ubuntu" {
  image = "ubuntu-22-04-x64"
  region = var.do_region
  size = "s-1vcpu-1gb"
}

build {
  name    = "nocodb-aws"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

   provisioner "shell" {
      scripts = [
        "scripts/install_nocodb.sh"
      ]
   }
}

build {
  name    = "nocodb-azure"
  sources = [
    "source.azure-arm.ubuntu"
  ]

   provisioner "shell" {
      scripts = [
        "scripts/install_nocodb.sh"
      ]
   }
}

build {
  name    = "nocodb-do"
  sources = [
    "source.digitalocean.ubuntu"
  ]

   provisioner "shell" {
      scripts = [
        "scripts/install_nocodb.sh"
      ]
   }
}
