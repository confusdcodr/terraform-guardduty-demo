terragrunt = {
  remote_state {
    backend = "s3"

    config {
      region         = "${get_env("AWS_DEFAULT_REGION", "")}"
      # profile        = "summer-intern-proj"
      bucket         = "guardduty-demo"
      key            = "tfstate/${path_relative_to_include()}/terraform.tfstate"
      encrypt        = false
      dynamodb_table = "guardduty-demo"
    }
  }

  terraform {
    source = "modules/account/"
  }
}

tags = {
    Project = "Guardduty Demo"
}

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