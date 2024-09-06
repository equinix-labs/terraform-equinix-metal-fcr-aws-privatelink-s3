terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the Equinix Provider
provider "equinix" {}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "random" {}
