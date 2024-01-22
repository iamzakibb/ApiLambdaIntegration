variable "function_name" {
  type = string
  default = ""
  description = "Name of the existing lambda function"
}

# ----------------------------------------------------------------------
# Default AWS Region used to deploy resources
# ----------------------------------------------------------------------
variable "aws_region" {
  default = "us-east-1"
}

