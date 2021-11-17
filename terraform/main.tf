
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_iam_role" "nike_iam_for_lambda_dev" {
  name = "nike_iam_for_lambda_dev"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# resource "aws_lambda_function" "nike_lambda_dev" {
#   filename      = "backend/lambda/function/get/lambda_function.zip"
#   function_name = "nike_get_tasks"
#   role          = aws_iam_role.nike_iam_for_lambda_dev.arn
#   handler       = "lambda.handler"

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
#   source_code_hash = filebase64sha256("backend/lambda/function/get/lambda_function.zip")

#   runtime = "python3.8"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }

resource "aws_api_gateway_rest_api" "nike_apig" {
  name = "nike_apig"
}

resource "aws_api_gateway_resource" "nike_apig" {
  parent_id   = aws_api_gateway_rest_api.nike_apig.root_resource_id
  path_part   = "nike_apig"
  rest_api_id = aws_api_gateway_rest_api.nike_apig.id
}

resource "aws_api_gateway_method" "nike_apig" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.nike_apig.id
  rest_api_id   = aws_api_gateway_rest_api.nike_apig.id
}

resource "aws_api_gateway_integration" "nike_apig" {
  http_method = aws_api_gateway_method.nike_apig.http_method
  resource_id = aws_api_gateway_resource.nike_apig.id
  rest_api_id = aws_api_gateway_rest_api.nike_apig.id
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "nike_apig" {
  rest_api_id = aws_api_gateway_rest_api.nike_apig.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.nike_apig.id,
      aws_api_gateway_method.nike_apig.id,
      aws_api_gateway_integration.nike_apig.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "nike_apig" {
  deployment_id = aws_api_gateway_deployment.nike_apig.id
  rest_api_id   = aws_api_gateway_rest_api.nike_apig.id
  stage_name    = "dev"
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

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  tags = {
    Name        = "nike"
    Environment = "dev"
  }
}
