terraform output kubeconfig > ~/.kube/config
terraform output config-map-aws-auth > aws_auth.yaml
kubectl apply -f aws_auth.yaml
