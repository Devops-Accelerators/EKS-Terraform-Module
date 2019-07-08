# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table and association

# Datasource to get all AWS Region
data "aws_region" "current" {}

#Datasource to get all availability zone for the region
data "aws_availability_zones" "available" {}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "terraform-eks-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Create the Subnet
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

# Create a internet-gateway in the VPC created
resource "aws_internet_gateway" "terraform_ig" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags = {
    Name = "terraform-eks-ig"
  }
}

# Create a route table in the VPC created and attach the gateway
resource "aws_route_table" "terraform_rt" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform_ig.id}"
  }
}

# Associate Subnet and route table
resource "aws_route_table_association" "terraform_rta" {
  count = 2

  subnet_id      = "${aws_subnet.terraform_sub.*.id[count.index]}"
  route_table_id = "${aws_route_table.terraform_rt.id}"
}
