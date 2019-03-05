data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  terraform-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.cluster_endpoint}' --b64-cluster-ca '${var.cluster_certificate}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "terraform_lc" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.terraform-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.large"
  name_prefix                 = "terraform-eks-terraform"
  security_groups             = ["${aws_security_group.terraform-node.id}"]
  user_data_base64            = "${base64encode(local.terraform-node-userdata)}"
  key_name		      = "devops-jan"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terraform_ag" {
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.terraform_lc.id}"
  max_size             = 3
  min_size             = 1
  name                 = "terraform-eks-terraform"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
