terragrunt = {
  remote_state {
    backend = "s3"

    config {
      region = "us-east-1"

      #profile        = "intern"
      bucket         = "guardduty-demo"
      key            = "tfstate/${path_relative_to_include()}/terraform.tfstate"
      encrypt        = false
      dynamodb_table = "guardduty-demo"
    }
  }

  terraform {
    source = "modules/account"
  }
}

create_malicious_iam_user     = false
create_malicious_instance = true
create_app_server_windows = true
create_app_server_linux   = true
create_cloudtrail         = true
create_vpc_flow_logs      = true

vpc_id        = "vpc-9241cef5"
key_pair_name = "gowens-intern"
cidr_block = "172.31.0.0/16"

## all submodules
region = "us-east-1"
project_name = "guardduty-demo"
environment = "guardduty-demo"
permissions_boundary_arn = "arn:aws:iam::568850148716:policy/P3PowerUserAccess"

tags = {
  Project  = "Guardduty Demo"
  TeamName = "Test"
}

## remediation_db module
create_exceptions_table   = true
table_name = "ir_exceptions"

db_attributes = [
  {
    name = "rule"
    type = "S"
  },
  {
    name = "account_id"
    type = "S"
  },
]

