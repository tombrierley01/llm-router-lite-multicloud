terraform {
  backend "s3" {
    bucket         = "litellm-tf-state-lock"
    key            = "env/dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "litellm-tf-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" { region = "eu-west-2" }