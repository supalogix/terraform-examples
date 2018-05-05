provider "aws" {
  region = "${var.aws_region}"
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

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    private_key           = "${file("secrets/private_key")}"
    git_tag               = "master"
    aws_access_key_id     = "${aws_iam_access_key.logs.id}"
    aws_secret_access_key = "${aws_iam_access_key.logs.secret}"
  }
}

resource "aws_launch_configuration" "example" {
  instance_type = "${var.instance_type}"

  image_id = "${data.aws_ami.ubuntu.id}"

  security_groups = ["${aws_security_group.example-sec-group.id}"]

  key_name = "${var.key_name}"

  iam_instance_profile = "ec2-instance-profile"

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
  zone_id = "${var.zone_id}"

  name = "staging.helloworld.${var.domain_name}"

  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.example.dns_name}"]
}

resource "aws_cloudwatch_log_group" "docker_logs" {
  name              = "${var.log_group_name}"
  retention_in_days = "${var.log_retention_days}"
}

resource "aws_iam_user" "logs" {
  name = "logs"
  path = "/apps/"
}

resource "aws_iam_access_key" "logs" {
  user = "${aws_iam_user.logs.name}"
}

resource "aws_iam_user_policy_attachment" "logs_cloudwatch_full" {
  user       = "${aws_iam_user.logs.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ec2-cloudwatch" {
  name = "ec2-cloudwatch-poc"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2-instance-profile"
  roles = ["ec2-cloudwatch-poc"]
}

resource "aws_iam_role_policy_attachment" "ec2-cloudwatch-attachment" {
  role       = "${aws_iam_role.ec2-cloudwatch.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
