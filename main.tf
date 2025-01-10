terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-northeast-1"
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
    filename = data.archive_file.lambda.output_path
    function_name = "remix-app-lambda"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    role = aws_iam_role.iam-for-lambda.arn

    handler = "index.handler"
    runtime = "nodejs22.x"
}
