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

