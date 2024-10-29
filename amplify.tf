# Configure the AWS Provider
provider "aws" {
  region     = var.region
}

resource "aws_amplify_app" "pokedex" {
  name         = var.project_name
  repository   = var.github_repo_url
  access_token = var.oauth_token


  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
version: 1
frontend:
  phases:
    build:
      commands: []
  artifacts:
    baseDirectory: /
    files:
      - "**/*"
  cache:
    paths: []
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = "dev"
  }
}

resource "aws_amplify_branch" "dev" {
  app_id            = aws_amplify_app.pokedex.id
  branch_name       = var.github_branch_dev
  enable_auto_build = true

  stage               = var.stage_dev
  enable_notification = true

  # Despliega automáticamente cuando se crea la rama
  depends_on = [aws_amplify_app.pokedex]

}

resource "aws_amplify_branch" "qa" {
  app_id            = aws_amplify_app.pokedex.id
  branch_name       = var.github_branch_qa
  enable_auto_build = true

  stage               = var.stage_qa
  enable_notification = true

  # Despliega automáticamente cuando se crea la rama
  depends_on = [aws_amplify_app.pokedex]

}

resource "aws_amplify_branch" "prod" {
  app_id            = aws_amplify_app.pokedex.id
  branch_name       = var.github_branch_prod
  enable_auto_build = true

  stage               = var.stage_prod
  enable_notification = true

  depends_on = [aws_amplify_app.pokedex]

}
