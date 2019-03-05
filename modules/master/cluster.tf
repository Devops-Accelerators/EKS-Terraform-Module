resource "aws_eks_cluster" "terraform_cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.terraform-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.terraform-cluster.id}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.terraform-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.terraform-cluster-AmazonEKSServicePolicy",
  ]
}
