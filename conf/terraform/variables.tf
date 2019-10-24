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
    "ons:owner" = "Ian Dash:ian.dash@ons.gov.uk"
  }
}

variable "external_ingress_cidrs" {
  description = "List of allowed CIDR ranges for ingress"
}

variable "flask_secret_key" {
  description = "Flask secret key for sessions"
}

variable "app_domain" {
  description = "Domain used for flask app"
}

variable "app_auth_domain" {
  description = "hosted UI domain setup for app"
}

variable "saml_idp_metadata_url" {
  description = "SAML IDP Metadate URL"
}