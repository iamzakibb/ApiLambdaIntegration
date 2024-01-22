variable "function_name" {
  type = string
  default = ""
  description = "Name of the existing lambda function"
}

# ----------------------------------------------------------------------
# Default AWS Region used to deploy resources
# ----------------------------------------------------------------------
variable "aws_region" {
  default = ""
}

# ----------------------------------------------------------------------
# Application name used for naming resources
# ----------------------------------------------------------------------
variable "app_name" {
  default = ""
}

# ----------------------------------------------------------------------
# Lambda functions, used to retrieve function ARN CFN exports
# ----------------------------------------------------------------------
variable "api_lambda_functions" {
  default = [
    "get-data",
    "put-data"
  ]
}

# ----------------------------------------------------------------------
# Lambda invoke URI prefix used in openAPI specification
# ----------------------------------------------------------------------
variable "lambda_invoke_uri_prefix" {
  default = "arn:aws:apigateway:ap-southeast-2:lambda:path/2015-03-31/functions"
}
