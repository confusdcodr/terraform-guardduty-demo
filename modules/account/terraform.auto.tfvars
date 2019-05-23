  create_exceptions_table   = true
  create_malicious_user     = true
  create_malicious_instance = true
  create_app_server_windows = true
  create_app_server_linux   = true
  create_cloudtrail         = true
  create_vpc_flow_logs      = true

  vpc_id        = "vpc-9241cef5"
  key_pair_name = "gowens-intern"
  cidr_block = "172.31.0.0/16"