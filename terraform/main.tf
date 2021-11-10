
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_dynamodb_table" "nike-db-dev" {
  name           = "nike-dev"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "HK"
  range_key      = "RK"

  attribute {
    name = "HK"
    type = "S"
  }

  attribute {
    name = "RK"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "nike"
    Environment = "dev"
  }
}
