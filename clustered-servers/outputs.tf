output "dns_name" {
  value = "${aws_elb.example.dns_name}"
}

output "access_key" {
  value = "${aws_iam_access_key.logs.id}"
}

output "secret" {
  value = "${aws_iam_access_key.logs.secret}"
}
