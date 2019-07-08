provider "aws" {
  region = "ap-southeast-1"
}

module "network" {
  source = "../modules/network"
  cluster-name = "${var.cluster-name}"
}

module "master" {
  source = "../modules/master"
  
  cluster-name = "${var.cluster-name}"
  subnet_ids = "${module.network.subnet_ids}"
  vpc_id     = "${module.network.vpc_id}"
  node_sg    = "${module.worker.node_sg}"
  arn = "${module.worker.arn}" 
}

module "worker" {
  source = "../modules/worker"

  vpc_id          = "${module.network.vpc_id}"
  subnet_ids      = "${module.network.subnet_ids}"
  cluster_sg	  = "${module.master.cluster_sg}"
  cluster-name	  = "${var.cluster-name}"
  cluster_version = "${module.master.cluster_version}"
  cluster_endpoint = "${module.master.cluster_endpoint}"
  cluster_certificate = "${module.master.cluster_certificate}"
  instance_type	= "${var.instance_type}"
  no_of_instances = "${var.no_of_instances}"
  min_no_instances = "${var.min_no_instances}"
}

output "kubeconfig" {
  value = "${module.master.kubeconfig}"
}

output "config-map-aws-auth" {
  value = "${module.master.config_map_aws_auth}"
}
