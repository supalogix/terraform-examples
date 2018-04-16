provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "hello-world" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"

  tags = {
    Name = "hello world example"
  }

  vpc_security_group_ids = ["${aws_security_group.hello-world-sec-group.id}"]

  user_data = "${base64encode(file("user-data.sh"))}"

  key_name = "us-west-1"
}

resource "aws_security_group" "hello-world-sec-group" {
  name = "Hello World Security Group"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hello world security group"
  }
}

output "public_dns" {
  value = "${aws_instance.hello-world.public_dns}"
}
