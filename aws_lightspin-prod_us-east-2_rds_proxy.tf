import {
  to = aws_db_proxy.light_api
  id = "light-api"
}

resource "aws_db_proxy" "light_api" {
  name                   = "light-api"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 5400  # 1h30min
  require_tls            = false # wasn't enabled in the console
  role_arn               = "arn:aws:iam::145875358567:role/service-role/rds-proxy-role-1694096671734"
  vpc_security_group_ids = ["sg-0e5a1960c739e03d2"]
  vpc_subnet_ids = [
    "subnet-01c19ec6fa4a8bcd2",
    "subnet-0cf1f4c3d66540f2c",
    "subnet-055b6ed0c2efe951c",
    "subnet-091c5244f2c69a89d",
    "subnet-0b712add5be7f684c",
    "subnet-05eeb2e87468be887",
    "subnet-08e3841671bf96b0e",
    "subnet-0ec08cde06ea408db",
    "subnet-0cc969f64811560ff",
    "subnet-004e6e95b150b5b95"
  ]

  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "DISABLED" # wasn't enabled in the console
    secret_arn                = "arn:aws:secretsmanager:us-east-2:145875358567:secret:prod/light-api/externaluser-3ZsVbq"
  }

  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "DISABLED" # wasn't enabled in the console
    secret_arn                = "arn:aws:secretsmanager:us-east-2:145875358567:secret:prod/light-api/rds-GAs2Wm"
  }
}
