# terraform-apig-deployment-reduced-test-case

Reduced test case for https://github.com/terraform-providers/terraform-provider-aws/issues/162.

## Usage

1. Set up your [AWS Authentication](https://www.terraform.io/docs/providers/aws/index.html#authentication)
2. `terraform plan -out terraform.plan`
3. `terraform apply terraform.plan`
4. Invoke the test endpoint (`curl "$(terraform output test_endpoint)"`)
5. Change the integration response status code to `201`, plan, apply
6. Invoke the test endpoint again

As of the following versions, the status code response does not change (stays at `200`), indicating Terraform did not update the `aws_api_gateway_deployment` resource (i.e. did not re-deploy the API).

```
❯ terraform -version
Terraform v0.12.20
+ provider.aws v2.48.0
```

## Workaround

Uncomment the stage `variables` definition for a workaround, per https://github.com/terraform-providers/terraform-provider-aws/issues/162#issuecomment-532593939

## Author

© 2020 Tom Vincent <git@tlvince.com> (https://tlvince.com)

## License

Released under the [MIT license](https://tlvince.mit-license.org).
