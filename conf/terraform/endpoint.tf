data "aws_subnet" default_az1 {
    availability_zone = "eu-west-2a"
    default_for_az = true
}

data "aws_subnet" default_az2 {
    availability_zone = "eu-west-2b"
    default_for_az = true
}

resource "aws_security_group" "allow_external_traffic" {
    name = "allow_external_traffic"
    description = "Allowed external traffic to auth-test LB"

    tags = merge(
        var.common_tags,
        {}
    )
}

resource "aws_security_group_rule" "allow_external_http" {
    type = "ingress"
    from_port = 0
    to_port = 80
    cidr_blocks = var.external_ingress_cidrs
    protocol = "tcp"
    description = "HTTP external ingress to ALB"
    security_group_id = "${aws_security_group.allow_external_traffic.id}"
}

resource "aws_security_group_rule" "allow_external_https" {
    type = "ingress"
    from_port = 0
    to_port = 443
    cidr_blocks = var.external_ingress_cidrs
    protocol = "tcp"
    description = "HTTPS external ingress to ALB"
    security_group_id = "${aws_security_group.allow_external_traffic.id}"
}

resource "aws_lb" "app_load_balancer" {
    load_balancer_type = "application"
    subnets = [
        "${data.aws_subnet.default_az1.id}",
        "${data.aws_subnet.default_az2.id}"
    ]
    security_groups = ["${aws_security_group.allow_external_traffic.id}"]
    tags = merge(
        var.common_tags,
        {
            "ons:application:resource" = "test_auth_app"
        }
    )
}

resource "aws_lb_target_group" "app_lb_target_group" {
    target_type = "lambda"

    health_check {
        enabled = true
        interval = 120
        timeout = 30
        path = "/"
    }

    tags = merge(
        var.common_tags,
        {
            "ons:application:resource" = "test_auth_app"
        }
    )
}

resource aws_lambda_permission "app_lb_lambda_permission" {
    action = "lambda:InvokeFunction"
    principal = "elasticloadbalancing.amazonaws.com"
    function_name = "${aws_lambda_function.test_auth_app.function_name}"
}

resource aws_lb_target_group_attachment bob {
    target_group_arn = "${aws_lb_target_group.app_lb_target_group.arn}"
    target_id = "${aws_lambda_function.test_auth_app.arn}"
}

resource "aws_acm_certificate" "app_ssl_cert" {
  domain_name       = "${var.app_domain}"
  validation_method = "DNS"

  tags = merge(
      var.common_tags,
      {}
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "app_load_balancer_https_listener" {
    load_balancer_arn = "${aws_lb.app_load_balancer.arn}"
    port = "443"
    protocol = "HTTPS"

    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "${aws_acm_certificate.app_ssl_cert.arn}"

    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.app_lb_target_group.arn}"
    }
}

resource "aws_lb_listener" "app_load_balancer_http_listener" {
    load_balancer_arn = "${aws_lb.app_load_balancer.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}
