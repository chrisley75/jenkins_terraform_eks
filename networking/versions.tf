terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }

  backend "s3" {
    bucket = "cley-eks-tfstate-bucket"
    key    = "cley-net-tfstate-key"
    region = "eu-west-3"
  }
}
