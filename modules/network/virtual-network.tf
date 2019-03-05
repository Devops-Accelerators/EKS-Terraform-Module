# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table and association


data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "terraform-eks-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "terraform_sub" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.terraform_vpc.id}"

  tags = "${
    map(
      "Name", "terraform-eks-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "terraform_ig" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags = {
    Name = "terraform-eks-ig"
  }
}

resource "aws_route_table" "terraform_rt" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform_ig.id}"
  }
}

resource "aws_route_table_association" "terraform_rta" {
  count = 2

  subnet_id      = "${aws_subnet.terraform_sub.*.id[count.index]}"
  route_table_id = "${aws_route_table.terraform_rt.id}"
}
