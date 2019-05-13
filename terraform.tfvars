terragrunt = {
  remote_state {
    backend = "s3"

    config {
      region         = "us-east-1"
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
create_exceptions_table = true
create_malicious_user = false
create_malicious_instance = false
resource_name = "testing"
environment = "guardduty-demo"

tags = {
    Project = "Guardduty Demo"
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