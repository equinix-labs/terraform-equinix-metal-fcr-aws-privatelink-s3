# common
variable "notifications_emails" {
  description = "Array of contact emails"
  type        = list(string)
}
variable "metro_code" {
  description = "Location metro code. You will need to update aws_region accordingly"
  default     = "SV"
}

# metal
variable "metal_project_id" {
  description = "ID of the Metal project where the resources are scoped to"
}
variable "metal_plan" {
  description = "The Metal device plan slug"
  default     = "c3.small.x86"
}
variable "metal_operating_system" {
  description = "The Metal The operating system slug"
  default     = "ubuntu_24_04"
}
variable "metal_bgp_asn" {
  description = "value"
  default     = "65000"
}
variable "metal_bgp_peer_subnet" {
  description = "value"
  default     = "101.1.1.0/31"
}

# fabric
variable "fabric_project_id" {
  description = "Project UUID where the Fabric resources are scoped to"
}
variable "fabric_account_number" {
  description = "Billing account number for Network Edge devices"
}
variable "fabric_metal_connection_speed" {
  description = "value"
  default     = 100
}
variable "fabric_aws_connection_speed" {
  description = "value"
  default     = 100
}
variable "fabric_aws_service_profile" {
  description = "value"
  default     = "AWS Direct Connect"
}

# aws
variable "aws_account_id" {
  description = "AWS Account ID"
}
variable "aws_region" {
  description = "AWS region code - https://www.aws-services.info/regions.html"
  default     = "us-west-1"
}
