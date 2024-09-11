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


terraform {
  required_providers {
    awsutils = {
      source = "cloudposse/awsutils"
      # For local development,
      # install the provider on local computer by running `make install` from the root of the repo, and uncomment the 
      # version below
      # version = "9999.99.99"
    }
  }
}
# Delete the default VPC in our account/region
resource "awsutils_default_vpc_deletion" "default" {
}