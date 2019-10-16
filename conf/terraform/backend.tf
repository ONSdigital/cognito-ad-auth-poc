# Backend S3 + Dynamo DB for locking
terraform {
  backend "s3" {
    
    bucket         = "cognito-app-auth-test"
    key            = "cognito-app-auth-test/terraform.tfstate"
    region         = "eu-west-2" # NB: No var usage allowed in in backend setup
    dynamodb_table = "cognito-app-auth-test"
    encrypt        = true
  }
}
