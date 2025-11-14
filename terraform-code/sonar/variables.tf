variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "key_name" {
  description = "Name for the SSH key pair"
  type        = string
  default     = "devops-demo"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project_tag" {
  description = "Project tag value"
  type        = string
  default     = "poc18"
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 30
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR Repository Name"
}