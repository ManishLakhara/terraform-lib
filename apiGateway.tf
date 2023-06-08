resource "aws_apigatewayv2_api" "example" {
  name                       = "my_websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "Lambda example"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.test_lambda.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_deployment" "example" {
  api_id      = aws_apigatewayv2_api.example.id
  description = "Example deployment"

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.example),
      jsonencode(aws_apigatewayv2_route.example_sendmessage),
    ])))
  }

  depends_on = [
    aws_apigatewayv2_route.example_sendmessage
  ]
}
resource "aws_apigatewayv2_route" "example_connect" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "$connect"
  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}
resource "aws_apigatewayv2_route" "example_disconnect" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "$disconnect"
  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}
resource "aws_apigatewayv2_route" "example_sendmessage" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "sendMessage"
  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.example.id
  name   = "version1"
}