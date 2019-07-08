# Mindtree-Devops-EKS
**EKS setup using Terraform**

**What is EKS ?**

Amazon Elastic Container Service for Kubernetes (Amazon EKS) makes it easy to deploy, manage, and scale containerized applications using Kubernetes on AWS.

**Why EKS ?**

1. Amazon EKS runs the Kubernetes management infrastructure for you across multiple AWS availability zones to eliminate a single point of failure. 
2. Amazon EKS is certified Kubernetes conformant so you can use existing tooling and plugins from partners and the Kubernetes community. 
3. Applications running on any standard Kubernetes environment are fully compatible and can be easily migrated to Amazon EKS.

**Resources that are created for EKS Master**
```
1. Create VPC.
2. Create 2 Subnets.
3. Internet gateway attacahed to VPC.
4. Route table for VPC.
5. Route table association.
6. Create IAM and attach 2 policy.
  - Cluster Policy
  - Service Policy
7. Security group for master with egress ( Outgoing Traffic Rule )
```

**Resources that are created for Worker Node**
```
1. Create IAM and attach 3 Policy
  - Worker Node Policy
  - CNI Policy
  - Container Registry Read Only Policy
2. Create instance profile for worker.
3. Worker node Security group 
  - Allow nodes to communicate with eachother.
  - Allow kubelets to receive communication from cluster  control plane(EKS Master).
  - Allow pods to communicate with cluster API.
4. Give permission to worker nodes to access EKS master cluster.
5. Need to autoscale worker-node.
6. Kubernetes configuration to join Worker Nodes to Master Cluster.
```

**How to Run the Terraform script ?**
1. go to **dev** folder and download all terraform plug-in.

```
   $ terraform init
```
2. Verify the resources that will be created and create a plan.
```
   $ terraform plan -out plan.out
```
3. apply the above created plan and setup the infrastructure for the AKS 
```
   $ terraform apply "plan.out"
```
4. Run the script file to configure kubectl
```
   $ ./script.sh
```
