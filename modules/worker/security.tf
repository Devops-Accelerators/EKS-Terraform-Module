#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

resource "aws_iam_role" "terraform-node" {
  name = "terraform-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "terraform-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.terraform-node.name}"
}

resource "aws_iam_role_policy_attachment" "terraform-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.terraform-node.name}"
}

resource "aws_iam_role_policy_attachment" "terraform-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.terraform-node.name}"
}

resource "aws_iam_instance_profile" "terraform-node" {
  name = "terraform-eks-terraform"
  role = "${aws_iam_role.terraform-node.name}"
}

resource "aws_security_group" "terraform-node" {
  name        = "terraform-eks-terraform-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-terraform-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "terraform-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.terraform-node.id}"
  source_security_group_id = "${aws_security_group.terraform-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "terraform-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.terraform-node.id}"
  source_security_group_id = "${var.cluster_sg}"
  to_port                  = 65535
  type                     = "ingress"
}