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


# Delete the default VPC in our account/region
resource "awsutils_default_vpc_deletion" "default" {
}