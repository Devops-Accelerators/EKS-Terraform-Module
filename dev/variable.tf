variable "cluster-name" {
  default = "terraform-eks"
}

variable "instance_type" {
  default = "t2.small"
}

variable "no_of_instances" {
  default = 3
}

variable "min_no_instances" {
  default = 3
}
