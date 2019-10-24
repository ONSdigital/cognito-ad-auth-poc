// user pool for auth
resource "aws_cognito_user_pool" "auth_test_user_pool" {
  name = "auth_test_user_pool"
  
  tags = merge(
    var.common_tags,
    {}
  )
}

// AWS hosted domain for user pool
resource "aws_cognito_user_pool_domain" "auth_test_app_domain" {
  domain = "app-auth-test"
  user_pool_id = "${aws_cognito_user_pool.auth_test_user_pool.id}"
}

// Attach OAuth / OIDC app to user pool
resource "aws_cognito_user_pool_client" "auth_test_app" {
  name = "Python test app"
    
  user_pool_id = "${aws_cognito_user_pool.auth_test_user_pool.id}"
  generate_secret = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "profile", "email"]
  supported_identity_providers = ["${aws_cognito_identity_provider.authzero_provider.provider_name}"]
  callback_urls = ["https://${var.app_domain}/login/cognito/authorized"]
  logout_urls = ["https://${var.app_domain}/logout"]
}

// SAML Identity provider for user pool federated login
resource "aws_cognito_identity_provider" "authzero_provider" {
  provider_name = "Auth0"
  provider_type = "SAML"
  provider_details = {
    "MetadataURL" = "${var.saml_idp_metadata_url}",
    "IDPSignout" = true 
  }
  user_pool_id = "${aws_cognito_user_pool.auth_test_user_pool.id}"
}