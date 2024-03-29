
data "aws_lambda_function" "existing" {
  function_name = var.function_name
}


module "api_gateway" {
  source = "../ApiGateway"

  name          = "Name of the Api Gateway"
  description   = "My API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
 
  integrations = {

    "ANY /" = {
      lambda_arn             = data.aws_lambda_function.existing.invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "GET /some-route" = {
      lambda_arn               = data.aws_lambda_function.existing.invoke_arn
      payload_format_version   = "2.0"
      authorization_type       = "JWT"
      authorizer_id            = aws_apigatewayv2_authorizer.some_authorizer.id
      throttling_rate_limit    = 80
      throttling_burst_limit   = 40
      detailed_metrics_enabled = true
    }

    "GET /some-route-with-authorizer" = {
      lambda_arn             = data.aws_lambda_function.existing.invoke_arn
      payload_format_version = "2.0"
      authorizer_key         = "cognito"
    }

    "GET /some-route-with-authorizer-and-scope" = {
      lambda_arn             = data.aws_lambda_function.existing.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "JWT"
      authorizer_key         = "cognito"
      authorization_scopes   = "tf/something.relevant.read,tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    }

    "GET /some-route-with-authorizer-and-different-scope" = {
      lambda_arn             = data.aws_lambda_function.existing.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "JWT"
      authorizer_key         = "cognito"
      authorization_scopes   = "tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    }

    "POST /start-step-function" = {
      integration_type    = "AWS_PROXY"
      integration_subtype = "StepFunctions-StartExecution"
      credentials_arn     = module.step_function.role_arn

      # Note: jsonencode is used to pass argument as a string
      request_parameters = jsonencode({
        StateMachineArn = module.step_function.state_machine_arn
      })

      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = data.aws_lambda_function.existing.invoke_arn
      tls_config = jsonencode({
        server_name_to_verify = local.domain_name
      })

      response_parameters = jsonencode([
        {
          status_code = 500
          mappings = {
            "append:header.header1" = "$context.requestId"
            "overwrite:statuscode"  = "403"
          }
        },
        {
          status_code = 404
          mappings = {
            "append:header.error" = "$stageVariables.environmentId"
          }
        }
      ])
    }

  }

}

module "api_gateway_lambda_integration" {
  source = "../Integration"

  region = var.region

  component = var.component
  deployment_identifier = var.deployment_identifier

  api_gateway_rest_api_id = module.api_gateway.api_gateway_rest_api_id
  api_gateway_rest_api_root_resource_id = module.api_gateway.api_gateway_rest_api_root_resource_id

  lambda_function_name = data.aws_lambda_function.existing.function_name

  depends_on = [
    module.api_gateway,
    module.lambda
  ]
}