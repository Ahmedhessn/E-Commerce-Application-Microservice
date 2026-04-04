
variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "vpc-name" {
  description = "VPC Name for our Jumphost server"
  type = string
  default = "Jumphost-vpc"
}

variable "igw-name" {
  description = "Internet Gate Way Name for our Jumphost server"
  type = string
  default = "Jumphost-igw"
}

variable "subnet-name1" {
  description = "Public Subnet 1 Name"
  type = string
  default = "Public-Subnet-1"
}

variable "subnet-name2" {
  description = "Subnet Name for our Jumphost server"
  type = string
  default = "Public-subnet2"
}

# Private subnet name variables
variable "private_subnet_name1" {
  description = "Private Subnet 1 Name"
  type = string
  default = "Private-subnet1"
}

variable "private_subnet_name2" {
  description = "Private Subnet 2 Name"
  type = string
  default = "Private-subnet2"
}

variable "rt-name" {
  description = "Route Table Name for our Jumphost server"
  type = string
  default = "Jumphost-rt"
}

variable "sg-name" {
  description = "Security Group for our Jumphost server"
  type = string
  default = "Jumphost-sg"
}

variable "eks_cluster_name" {
  description = "EKS cluster name for kubernetes.io/cluster/* subnet tags (must match eks-terraform cluster name)"
  type        = string
  default     = "project-eks"
}

variable "iam-role" {
  description = "IAM Role for the Jumphost Server"
  type = string
  default = "Jumphost-iam-role1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0150ccaf51ab55a51" // Replace with the latest AMI ID for your region
}

variable "instance_type" {
  description = "EC2 instance type for the jumphost (t3.medium is a sensible default; use t3.small only if cost is tight)"
  type        = string
  default     = "t3.medium"
}

variable "jumphost_use_spot" {
  description = "If true, launch as Spot for lower hourly cost. AWS may reclaim capacity (instance stops); not ideal if you need 24/7 SSH. For lowest cost when nobody needs the box: stop the instance in the console/CLI instead of relying on Spot."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2 keypair"
  type        = string
  default     = "jumphost-key"
}

variable "instance_name" {
  description = "EC2 Instance name for the jumphost server"
  type        = string
  default     = "Jumphost-server"
}
#
