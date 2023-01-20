terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }

  backend "s3" {
    bucket = "cley-eks-ansible-bucket"
    key    = "cley-net-ansible-key"
    region = "eu-west-3"
  }
}
