output "node_sg" {
  value = "${aws_security_group.terraform-node.id}"
}

output "arn" {
  value = "${aws_iam_role.terraform-node.arn}"
}
