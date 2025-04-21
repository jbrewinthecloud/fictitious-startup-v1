variable "version" {
  type    = string
  default = "1.0.0"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "cloudtalents-startup-v${var.version}"
  instance_type = "t2.micro"
  region        = "us-east-1" # You can change this if you're using another region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  vpc_id                     = "vpc-0737da03f25acca74"
  subnet_id                  = "subnet-035694339a4508f52"
  associate_public_ip_address = true

  ssh_username = "ubuntu"
}

build {
  name    = "cloudtalents-startup-image"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "."
    destination = "/tmp/app"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo mv /tmp/app/* /opt/app/",
      "sudo chown -R ubuntu:ubuntu /opt/app"
    ]
  }

  post-processor "amazon-ami-management" {
    keep_releases = 2
  }
}
