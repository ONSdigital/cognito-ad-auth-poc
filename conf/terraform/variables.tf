variable "region" {
  description = "AWS region"
  default = "eu-west-2"
}

variable "common_tags" {
  default = {
    "ons:environment" = "development",
    "ons:application" = "app-auth-test",
    "ons:application:lifecycle:type" = "sprint",
    "ons:application:lifecycle:eol" = "2019-10-18T12:00",
  }
}

variable "external_ingress_cidrs" {
  description = "List of allowed CIDR ranges for ingress"
}
