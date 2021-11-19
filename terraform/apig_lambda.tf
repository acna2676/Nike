# Variables
variable "task_region" {default = "ap-northeast-1"}

variable "accountId" {default = "197052146621"}

variable "get_tasks_function_name" {
  default = "get_tasks"
}
variable "post_tasks_function_name" {
  default = "post_tasks"
}
# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "nike_api"
}

resource "aws_api_gateway_resource" "tasks" {
  path_part   = "tasks"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "user_id" {
  path_part   = "{user_id}"
  parent_id   = aws_api_gateway_resource.tasks.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_method" "get_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "post_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
    rest_api_id             = aws_api_gateway_rest_api.api.id
    resource_id             = aws_api_gateway_resource.user_id.id
    http_method             = aws_api_gateway_method.get_tasks.http_method
    type                    = "AWS_PROXY"
    integration_http_method = "POST"
    # uri                     = "/tasks/{user_id}"
    uri                     = aws_lambda_function.get_tasks_function.invoke_arn
    # passthrough_behavior    = "WHEN_NO_MATCH"

#     request_parameters = {
#         "integration.request.path.id" = "method.request.path.user_id"
#     }
}
resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.user_id.id
  http_method             = aws_api_gateway_method.post_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_tasks_function.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.user_id.id,
      aws_api_gateway_method.get_tasks.id,
      aws_api_gateway_method.post_tasks.id,
      aws_api_gateway_integration.get_integration.id,
      aws_api_gateway_integration.post_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}

# Lambda
resource "aws_lambda_permission" "get_tasks" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_tasks_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.task_region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.get_tasks.http_method}/${aws_api_gateway_resource.tasks.path_part}/${aws_api_gateway_resource.user_id.path_part}"
}

resource "aws_lambda_permission" "post_tasks" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_tasks_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.task_region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post_tasks.http_method}/${aws_api_gateway_resource.tasks.path_part}/${aws_api_gateway_resource.user_id.path_part}"
}

# terraformにzip化してもらうための設定
data "archive_file" "get_function_zip" {
  type        = "zip"
  source_dir  = "backend/lambda/function/get"
  output_path = "backend/lambda/function/get/lambda_function.zip"
}

data "archive_file" "post_function_zip" {
  type        = "zip"
  source_dir  = "backend/lambda/function/post"
  output_path = "backend/lambda/function/post/lambda_function.zip"
}

resource "aws_lambda_function" "get_tasks_function" {
  filename      = "${data.archive_file.get_function_zip.output_path}"
  function_name = "${var.get_tasks_function_name}"
  role          = aws_iam_role.iam_role_for_lambda.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.get_tasks,
  ]

  source_code_hash = filebase64sha256("backend/lambda/function/get/lambda_function.zip")
}
resource "aws_lambda_function" "post_tasks_function" {
  filename      = "${data.archive_file.post_function_zip.output_path}"
  function_name = "${var.post_tasks_function_name}"
  role          = aws_iam_role.iam_role_for_lambda.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.post_tasks,
  ]

  source_code_hash = filebase64sha256("backend/lambda/function/post/lambda_function.zip")
}

# IAM
resource "aws_iam_role" "iam_role_for_lambda" {
  name = "task_role"

  assume_role_policy = <<POLICY
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
POLICY
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "get_tasks" {
  name              = "/aws/lambda/${var.get_tasks_function_name}"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "post_tasks" {
  name              = "/aws/lambda/${var.post_tasks_function_name}"
  retention_in_days = 14
}
# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_service_role" {
  name        = "lambda_service_role"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
     {
      "Action": [
        "dynamodb:Query",
        "dynamodb:PutItem"
      ],
      "Resource": "arn:aws:dynamodb:ap-northeast-1:197052146621:table/nike-dev",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.lambda_service_role.arn
}
