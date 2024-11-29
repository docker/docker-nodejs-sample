###############################################################################
# configuration
###############################################################################

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# configuration

// Define an IAM role for the EKS cluster control plane
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  // Specify the permissions for assuming this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach AmazonEKSClusterPolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

// Attach AmazonEKSServicePolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

// Create an EKS cluster
resource "aws_eks_cluster" "aws_eks" {
  name     = "kotak01-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  // Configure VPC for the EKS cluster
  vpc_config {
    subnet_ids = ["subnet-0ef22ee777f7e8973", "subnet-0a935738721fb6a60"]
  }

  // Add tags to the EKS cluster for identification
  tags = {
    Name = "EKS_demo"
  }
}

// Define an IAM role for EKS worker nodes
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-demo"

  // Specify the permissions for assuming this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach AmazonEKSWorkerNodePolicy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEKS_CNI_Policy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEC2ContainerRegistryReadOnly to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# data "aws_ami" "eks_worker_ami" {
#   filter {
#     name   = "name"
#     values = [""]
#   }

#   most_recent = true
#   #owners      = ["092701018921"] # Amazon EKS AMI account ID

#   # filter {
#   #   name   = "owner-id"
#   #   values = ["092701018921"]
#   # }

# }

# resource "aws_launch_template" "this" {
#   name_prefix            = "kotak01-eks-worker"
#   update_default_version = true
#   dynamic "block_device_mappings" {
#     for_each = data.aws_ami.eks_worker_ami.block_device_mappings
#     iterator = device
#     content {
#       device_name = device.value["device_name"]
#       ebs {
#         volume_size = 20
#         volume_type = gp3
#       }
#     }
#   }



# #   user_data     = "${base64encode(...)}"
#   instance_type = "t2.micro"
#   # option 1
#   image_id = data.aws_ami.eks_worker_ami.id
#   # option 2(unused)
#   # image_id = data.aws_ssm_parameter.eks_optimized_ami.value


#   vpc_security_group_ids = [""]

#   tag_specifications {
#     resource_type = "instance"
#   }
# }

// Create an EKS node group
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "node_demo"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0ef22ee777f7e8973", "subnet-0a935738721fb6a60"]

  // Configure scaling options for the node group
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"

    instance_types = ["t3.micro"]

    capacity_type  = "ON_DEMAND"

    disk_size      = 20

  // Ensure that the creation of the node group depends on the IAM role policies being attached
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}