#construccion de la base de datos en dynamo

resource "aws_dynamodb_table" "global_table" {
  name         = "PokemonTable"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"

  lifecycle {
    prevent_destroy = false
  }
}

# creacion de los roles y politicas

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Effect" : "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : aws_dynamodb_table.global_table.arn
      }
    ]
  })
}


#construccion de las lambdas
resource "aws_lambda_function" "fn_getPokemons_table" {
  function_name = "Fn_getPokemons_table"
  handler       = "lambda_getPokemons.lambda_handler"
  runtime       = "python3.10"
  timeout       = 60
  filename      = "../lambda/lambda_getPokemons.zip"
  role          = aws_iam_role.lambda_exec_role.arn
}

resource "aws_lambda_function" "fn_capturePokemons_table" {
  function_name = "Fn_capturePokemons_table"
  handler       = "lambda_capturePokemons.lambda_handler"
  runtime       = "python3.10"
  timeout       = 60
  filename      = "../lambda/lambda_capturePokemons.zip"
  role          = aws_iam_role.lambda_exec_role.arn
}

# creacion del api gateway

resource "aws_api_gateway_rest_api" "PokedexAPI" {
  name        = "PokedexAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.PokedexAPI.id
  parent_id   = aws_api_gateway_rest_api.PokedexAPI.root_resource_id
  path_part   = "Pokemones"
}

resource "aws_api_gateway_method" "getPokemons" {
  rest_api_id   = aws_api_gateway_rest_api.PokedexAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "capturePokemons" {
  rest_api_id   = aws_api_gateway_rest_api.PokedexAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "getPokemons_integration" {
  rest_api_id             = aws_api_gateway_rest_api.PokedexAPI.id
  resource_id             = aws_api_gateway_resource.MyDemoResource.id
  http_method             = aws_api_gateway_method.getPokemons.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fn_getPokemons_table.invoke_arn
}

resource "aws_api_gateway_integration" "capturePokemons_integration" {
  rest_api_id             = aws_api_gateway_rest_api.PokedexAPI.id
  resource_id             = aws_api_gateway_resource.MyDemoResource.id
  http_method             = aws_api_gateway_method.capturePokemons.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fn_capturePokemons_table.invoke_arn
}


# Permisos de Invocación para API Gateway

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_getPokemons_table.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.PokedexAPI.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_post" {
  statement_id  = "AllowAPIGatewayInvokePost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_capturePokemons_table.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.PokedexAPI.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "PokedexAPI_deployment" {
  rest_api_id = aws_api_gateway_rest_api.PokedexAPI.id
  depends_on = [
    aws_api_gateway_integration.getPokemons_integration,
    aws_api_gateway_integration.capturePokemons_integration,
  ]
}

# Creacion del stage para el endpoint

resource "aws_api_gateway_stage" "PokedexAPI_stage" {
  stage_name    = "Pokedex"
  rest_api_id   = aws_api_gateway_rest_api.PokedexAPI.id
  deployment_id = aws_api_gateway_deployment.PokedexAPI_deployment.id
}





resource "null_resource" "write_api_url" {
  provisioner "local-exec" {
    command = <<EOT
    echo ${aws_api_gateway_stage.PokedexAPI_stage.invoke_url}/${aws_api_gateway_resource.MyDemoResource.path_part} > api_gateway_url.txt
    EOT
  }

  depends_on = [aws_api_gateway_stage.PokedexAPI_stage]
}

