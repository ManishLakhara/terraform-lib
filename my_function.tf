data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "my_function"
  role          = "arn:aws:iam::715153418817:role/lambda_tf"
  handler       = "index.handler"
  layers = ["arn:aws:lambda:us-east-1:715153418817:layer:aws-sdk:1"]

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"
  timeout = "10"
  environment {
    variables = {
      WEBSOCKET_URL = aws_apigatewayv2_stage.example.invoke_url
    }
  }
}

