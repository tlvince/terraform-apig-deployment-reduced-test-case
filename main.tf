provider "aws" {
  region = "eu-west-2"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "tlvince-test-terraform"
  description = "Reduced test case for terraform-provider-aws#162"
}

resource "aws_api_gateway_resource" "test_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "test_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.test_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "test_get_integration_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.test_resource.id
  http_method = aws_api_gateway_method.test_get_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "response_success" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.test_resource.id
  http_method = aws_api_gateway_method.test_get_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "test_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.test_resource.id
  http_method = aws_api_gateway_method.test_get_method.http_method
  status_code = aws_api_gateway_method_response.response_success.status_code

  response_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  depends_on = [
    aws_api_gateway_integration.test_get_integration_request
  ]
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "test"

  # Terraform only redeploys the API when the api_deployment resource itself
  # changes, not if any of the underlying resources change.
  #
  # Workaround by hashing the contents of the underlying resources and updating
  # a property on the api_deployment resource. Note, this list needs to be
  # maintained.
  #
  # See https://github.com/terraform-providers/terraform-provider-aws/issues/162
  # variables = {
  #   deployment_id = sha256(join("", [
  #     jsonencode(aws_api_gateway_resource.test_resource),
  #     jsonencode(aws_api_gateway_method.test_get_method),
  #     jsonencode(aws_api_gateway_integration.test_get_integration_request),
  #     jsonencode(aws_api_gateway_method_response.response_success),
  #     jsonencode(aws_api_gateway_integration_response.test_get_integration_response),
  #   ]))
  # }

  depends_on = [
    aws_api_gateway_integration.test_get_integration_request
  ]
}
