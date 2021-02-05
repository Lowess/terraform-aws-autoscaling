### Backend definition

provider "aws" {
  region = var.aws_region
}

### Module Main

######################################################################
## Fetch AWS data
######################################################################

module "discovery" {
  source              = "github.com/Lowess/terraform-aws-discovery?ref=master"
  aws_region          = var.aws_region
  vpc_name            = var.vpc_name
  ec2_ami_names       = [var.app_ami_name]
  ec2_security_groups = []
  ec2_ami_owners      = var.app_ami_owner
}

data "http" "whatismyip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  app_ami_id  = module.discovery.images_id[0]
  app_subnets = module.discovery.public_subnets
  app_azs     = keys(module.discovery.public_subnets_json)

  my_ip = jsondecode(data.http.whatismyip.body).ip
}

