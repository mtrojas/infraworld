provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "infraworld" {
  ami                    = "ami-01e7ca2ef94a0ae86"
  key_name               = "mt-infra"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.secgroup-infraworld.id]

  // Adding the meta-argument depends_on to ensure I am able to SSH to the instance with the recently created aws_key_pair
  depends_on = [aws_key_pair.mt-infra]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, InfraWorld" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name = "infraworld"
  }
}

resource "aws_security_group" "secgroup-infraworld" {
  name = "secgroup-infraworld"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = var.http_port
    to_port          = var.http_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = var.https_port
    to_port          = var.https_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_key_pair" "mt-infra" {
  key_name   = "mt-infra"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/GUi92INU//3mh1BVf+Y/tOYimrEgqsg+E9wwmszGmXBYX9G0XVwRFOPqalyfiARn+e4VX1KNq69JECt2m+5Aj8/Vc11ilc1Nj/NzjCAk3QKZ00Dg9KF15TBsYCXCZZoFTeBfhRh/SxPXziFltfKAPeTev/tRkM+LwKIzLF9MMOEZrn7BCzDOXc6ox1tiZmjtNV/5smAYMrDTZuLqDIxAI9Z93r0lZrS8azDpMBIub2CKoMaJdALJad7EFD//jp+CxVFrqBTqVmrFGmDfgiUaxNLgeZRILEJH0+nSetNBaRJXmLcJumxJELf5gv7Yq7vGc2km9D7jfPgWyJcldW0B mtrojas@MTs-MacBook"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "The port the server will use for SSH connections"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "The port the server will use for HTTP connections"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The port the server will use for HTTPS connections"
  type        = number
  default     = 443
}

output "public_ip" {
  value       = aws_instance.infraworld.public_ip
  description = "The public IP of the web server"
}


