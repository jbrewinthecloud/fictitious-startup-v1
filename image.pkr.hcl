packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "cloudtalents-startup-v${var.version}"
  instance_type = "t2.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  vpc_id                      = "vpc-0737da03f25acca74"
  subnet_id                   = "subnet-035694339a4508f52"
  associate_public_ip_address = true
  ssh_username                = "ubuntu"
}

build {
  name    = "cloudtalents-startup-image"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "app.zip"
    destination = "/tmp/app.zip"
  }

# First install unzip
provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unzip"
  ]
}
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo unzip /tmp/app.zip -d /opt/app",
      "sudo chown -R ubuntu:ubuntu /opt/app"
    ]
  }
}
