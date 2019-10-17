data "archive_file" "lambda_bundle" {
    type="zip"
    source_file = "${path.module}/../../cognito_login_test.py"
    output_path = "${path.module}/files/fn_pkg.zip"
}

resource "aws_iam_role" "basic_lambda_role" {
    name = "basic-lambda-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic_lambda_role_policy" {
  role = "${aws_iam_role.basic_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
} 

resource "aws_lambda_layer_version" "flask_layer" {
  layer_name = "flask_layer"
  filename = "${path.module}/../../flask_layer.zip"
  source_code_hash = filebase64sha256("../../flask_layer.zip")
  compatible_runtimes = ["python3.7"]
}

resource "aws_lambda_function" "test_auth_app" {
    function_name = "cognito_login_test"
    description = "Test Lambda function to test out cognito auth for apps."
    filename = "${data.archive_file.lambda_bundle.output_path}"
    source_code_hash = filebase64sha256(data.archive_file.lambda_bundle.output_path)
    handler = "cognito_login_test.lambda_handler"
    runtime = "python3.7"

    layers = ["${aws_lambda_layer_version.flask_layer.arn}"]

    role = "${aws_iam_role.basic_lambda_role.arn}"
    
    tags = merge(
      var.common_tags,
      {}
    )
    
}
