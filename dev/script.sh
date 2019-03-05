terraform output config_map_aws_auth > aws.yaml
terraform output kubeconfig > ~/.kube/config
kubectl apply -f aws.yaml
