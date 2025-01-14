terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }

  required_version = ">= 1.2.0"
}
variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "ap-northeast-1"
}
provider "aws" {
  region  = var.aws_region
}


data "aws_iam_policy_document" "assume-role" {
    statement {
      effect = "Allow"

      principals {
        type = "Service"
        identifiers = [ "lambda.amazonaws.com" ]
      }
      actions = [ "sts:AssumeRole" ]
    }
}

resource "aws_iam_role" "iam-for-lambda" {
    name = "iam-for-lambda"
    assume_role_policy = data.aws_iam_policy_document.assume-role.json
}


# Package Lambda Function
data "archive_file" "lambda" {
    type = "zip"
    source_dir = "./remix-app/build"
    output_path = "lambda-function.zip"

}
# Lambda Function
resource "aws_lambda_function" "remix-app" {
    function_name = "remix-app-lambda"
    filename = data.archive_file.lambda.output_path
    source_code_hash = data.archive_file.lambda.output_base64sha256
    role = aws_iam_role.iam-for-lambda.arn

    runtime = "nodejs22.x"
    handler = "index.handler"
    layers = [ "arn:aws:lambda:${var.aws_region}:753240598075:layer:LambdaAdapterLayerX86:23" ]

    environment {
      variables = {
        AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
        NODE_ENV = "production"
        PORT = "3000"
      }
    }
}

# TODO: CloudFront
