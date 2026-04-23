# infra/variables.tf

variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Unique name for your S3 bucket"
  default     = "amr-saad-devops-portfolio-2026" 
}
