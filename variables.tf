variable "aws_region" {
  description = "AWS region for this example"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Short prefix used in AWS resource names"
  type        = string
  default     = "ccaws-tf03"
}

variable "instance_type" {
  description = "EC2 instance type for the target instances"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Application port used by Nginx on the EC2 instances"
  type        = number
  default     = 8080
}
