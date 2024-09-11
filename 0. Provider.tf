provider "aws" {
  region = local.region
}

terraform {
  cloud {

    organization = "KuTest"

    workspaces {
      name = "VPC-DMZ"
    }
  }
}

resource "aws_default_vpc" "default" {
  force_destroy = true
}
