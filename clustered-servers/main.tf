provider "aws" {
  region = "us-west-1"
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    private_key = "${file("secrets/private_key")}"
  }
}

resource "aws_launch_configuration" "example" {
  instance_type = "t2.micro"
  image_id      = "ami-07585467"

  security_groups = ["${aws_security_group.example-sec-group.id}"]

  key_name = "us-west-1"

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "example-sec-group" {
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "asg example security group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers = ["${aws_elb.example.name}"]

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

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
}

resource "aws_route53_record" "my-elb-cname" {
  zone_id = "ZVITZ49QALIA8"
  name    = "helloworld.jonathannacionales.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.example.dns_name}"]
}

output "dns_name" {
  value = "${aws_elb.example.dns_name}"
}
