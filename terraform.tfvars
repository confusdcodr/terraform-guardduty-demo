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

## all submodules
region = "us-east-1"
project_name = "guardduty-demo"
environment = "guardduty-demo"

tags = {
  Project  = "Guardduty Demo"
  TeamName = "Test"
}

## remediation_db module
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

## malicious instance
permissions_boundary_arn = "arn:aws:iam::568850148716:policy/P3PowerUserAccess"
