provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-07585467"

  tags = {
    Name = "terraform example"
  }

  vpc_security_group_ids = ["${aws_security_group.example-sec-group.id}"]

  key_name = "us-west-1"

  provisioner "local-exec" {
    command = "tar cfz app.tar.gz app"
  }

  provisioner "file" {
    source      = "./app.tar.gz"
    destination = "/home/ubuntu/app.tar.gz"

    connection {
      user        = "ubuntu"
      private_key = "${file("./us-west-1.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python",
      "sudo apt-get install -y docker.io",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "tar zxvf app.tar.gz",
      "cd app",
      "sudo docker-compose up -d",
    ]

    connection {
      user        = "ubuntu"
      private_key = "${file("./us-west-1.pem")}"
    }
  }
}

resource "aws_security_group" "example-sec-group" {
  name = "Example Security Group"

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
    Name = "example security group"
  }
}

output "public_dns" {
  value = "${aws_instance.example.public_dns}"
}
