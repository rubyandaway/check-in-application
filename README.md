# Deploy the IdentityE2E application to AWS Cloud using AWS EKS with Terraform

##Steps:
- Provision AWS EKS cluster
- Create Docker images from Dockerfile and push to repository
- Create and provision Terraform infrastructure with the commands :

```bash
terraform init
terraform plan
terraform apply
```

It might take a while for the cluster to be creates (up to 15-20 minutes).

As soon as cluster is ready, you should find a `kubeconfig_my-cluster` kubeconfig file in the current directory.


##Considerations
The AWS Cloud Elastic Kubernetes Service was chosen for this deployment; this was mainly due to Kubernetes’s native horizontal and vertical pod autoscaling handles scaling at the application level.

Kubernetes provides capabilities that efficiently orchestrate containerized applications. 
This is mainly achieved through the automation of the provisioning processes. A Kubernetes "Deployment" enables you to automate the behavior of pods. 
Instead of manually maintaining the application lifecycle, you can use "Deployments" to define how behavior is automated
It is also cost-efficient at £0.10/hour