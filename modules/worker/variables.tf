variable "vpc_id" {
}

variable "cluster-name" {
}

variable "cluster_sg" {
}

variable "cluster_version" {
}

variable "cluster_endpoint" {
}

variable "cluster_certificate" {
}

variable "subnet_ids" {
  type = "list"
}

variable "instance_type" {
}

variable "no_of_instances" {
}

variable "min_no_instances" {
}
