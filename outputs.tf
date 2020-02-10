output "test_endpoint" {
  value = join("/", [
    aws_api_gateway_deployment.api_deployment.invoke_url,
    aws_api_gateway_resource.test_resource.path_part
  ])
}
