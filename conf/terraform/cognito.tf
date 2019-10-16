// user pool for auth
resource "aws_cognito_user_pool" "auth_test_user_pool" {
  name = "auth_test_user_pool"
  
  tags = merge(
    var.common_tags,
    {}
  )
}

resource "aws_cognito_user_pool_domain" "auth_test_app_domain" {
  domain = "app-auth-test"
  user_pool_id = "${aws_cognito_user_pool.auth_test_user_pool.id}"
}

# // attach app to user pool
# resource "aws_cognito_user_pool_client" "auth_test_app" {
#   name = "Python test app"
    
#   user_pool_id = "${aws_cognito_user_pool.auth_test_user_pool.user_pool_id}"
#   generate_secret = true
#   callback_urls = [""]

#   tags = merge(
#     var.common_tags,
#     {}
#   )
# }