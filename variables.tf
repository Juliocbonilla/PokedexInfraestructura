variable "project_name" {
  description = "The name of the Amplify project"
  type        = string

}

variable "github_repo_url" {
  description = "GitHub repository URL for the Amplify project"
  type        = string

}

variable "github_branch_dev" {
  description = "Branch to deploy from"
  type        = string

}

variable "github_branch_qa" {
  description = "Branch to deploy from"
  type        = string

}

variable "github_branch_prod" {
  description = "Branch to deploy from"
  type        = string

}

variable "region" {
  description = "Region where AWS resources will be created"
  type        = string

}

variable "oauth_token" {
  description = "oauth_token"
  type        = string

}


variable "stage_dev" {
  description = "secret_key"
  type        = string

}

variable "stage_qa" {
  description = "secret_key"
  type        = string

}

variable "stage_prod" {
  description = "secret_key"
  type        = string

}



variable "input_template" {
  description = "secret_key"
  type        = string

}

variable "email_addresses" {
  type    = list(string)
  default = ["email1@example.com", "email2@example.com", "email3@example.com"]
}
