provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "check-in-cluster"
}

#module "vpc" {
#  source  = "terraform-aws-modules/vpc/aws"
#  version = "2.47.0"
#
#  name                 = "k8s-vpc"
#  cidr                 = "10.16.0.0/16"
#  azs                  = data.aws_availability_zones.available.names
#  private_subnets      = ["10.16.1.0/24", "10.16.2.0/24", "10.16.3.0/24"]
#  public_subnets       = ["10.16.4.0/24", "10.16.5.0/24", "10.16.6.0/24"]
#  enable_nat_gateway   = true
#  single_nat_gateway   = true
#  enable_dns_hostnames = true
#
#  public_subnet_tags = {
#    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#    "kubernetes.io/role/elb"                      = "1"
#  }
#
#  private_subnet_tags = {
#    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#    "kubernetes.io/role/internal-elb"             = "1"
#  }
#}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "k8s-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

#module "eks" {
#  source  = "terraform-aws-modules/eks/aws"
#  version = "18.0"
#
#  cluster_name    = local.cluster_name
#  cluster_version = "1.17"
#  subnets         = module.vpc.private_subnets
#
#  vpc_id = module.vpc.vpc_id
#
#  node_groups = {
#        public = {
#          subnets          = [module.vpc.public_subnets]
#          desired_capacity = 1
#          max_capacity     = 10
#          min_capacity     = 1
#
#          instance_type = "t2.small"
#          k8s_labels = {
#            Environment = "public"
#          }
#        }
#        private = {
#          subnets          = [module.vpc.private_subnets]
#          desired_capacity = 1
#          max_capacity     = 10
#          min_capacity     = 1
#
#          instance_type = "t2.small"
#
#          k8s_labels = {
#            Environment = "private"
#          }
#        }
#
#  }
#
##  write_kubeconfig   = true
##  config_output_path = "./"
#}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                = "worker-group-1"
      instance_type       = "t2.small"
      additional_userdata = "echo foo bar"
      #      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity = 2
    },
    {
      name                = "worker-group-2"
      instance_type       = "t2.medium"
      additional_userdata = "echo foo bar"
      #      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity = 1
    },
  ]
}

