provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "registry" {
  instance_type = "t2.micro"

  ami = "${data.aws_ami.ubuntu.id}"

  vpc_security_group_ids = ["${aws_security_group.docker-registry-sec-group.id}"]

  key_name = "us-west-1"

  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_security_group" "docker-registry-sec-group" {
  name = "Auto Scaling Group Secrity Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "docker registry security group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"
}

resource "aws_route53_record" "docker-registry-cname" {
  zone_id = "ZVITZ49QALIA8"

  name = "registry.jonathannacionales.com"

  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.registry.public_dns}"]
}

output "dns_name" {
  value = "${aws_instance.registry.public_dns}"
}
