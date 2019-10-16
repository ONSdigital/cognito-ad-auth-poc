output "lb_ip" {
    value = "${aws_lb.app_load_balancer.dns_name}"
}