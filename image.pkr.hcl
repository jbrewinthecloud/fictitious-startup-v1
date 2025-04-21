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

      - name: Zip application contents
        run: |
          zip -r app.zip . -x ".git/*" ".github/*" "secrets.sh"

build {
  name    = "cloudtalents-startup-image"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
  source      = "app.zip"
  destination = "/tmp/app.zip"
}

provisioner "shell" {
  inline = [
    "mkdir -p /opt/app",
    "unzip /tmp/app.zip -d /opt/app",
    "chown -R ubuntu:ubuntu /opt/app"
  ]
}


provisioner "shell" {
  inline = [
    "mkdir -p /opt/app",
    "unzip /tmp/app/app.zip -d /opt/app",
    "chown -R ubuntu:ubuntu /opt/app"
  ]
}

