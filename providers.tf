terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}


# Identify cloud provider details. 
provider "aws" {
  region  = "us-west-2"
}
