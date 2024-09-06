# --- FABRIC CLOUD ROUTER ---

resource "equinix_fabric_cloud_router" "this" {
  name = local.name_prefix
  type = "XF_ROUTER"

  notifications {
    type   = "ALL"
    emails = var.notifications_emails
  }
  location {
    metro_code = var.metro_code
  }
  package {
    code = "STANDARD"
  }
  project {
    project_id = var.fabric_project_id
  }
  account {
    account_number = var.fabric_account_number
  }
}

# --- FABRIC CONNECTION TO METAL ---

module "cloud_router_2_metal_connection" {
  source  = "equinix/fabric/equinix//modules/cloud-router-connection"
  version = "0.12.0"

  connection_name      = "${local.name_prefix}-metal"
  connection_type      = "IP_VC"
  notifications_type   = "ALL"
  notifications_emails = var.notifications_emails
  project_id           = var.fabric_project_id
  bandwidth            = var.fabric_metal_connection_speed

  #Aside
  aside_fcr_uuid = equinix_fabric_cloud_router.this.id

  #Zside
  zside_ap_type               = "METAL_NETWORK"
  zside_ap_authentication_key = equinix_metal_connection.this.authorization_code
}

resource "equinix_fabric_routing_protocol" "metal_direct" {
  connection_uuid = module.cloud_router_2_metal_connection.primary_connection_id
  name            = "${local.name_prefix}-metal-direct"
  type            = "DIRECT"

  direct_ipv4 {
    equinix_iface_ip = "${local.fabric_router_ip}/${split("/", var.metal_bgp_peer_subnet)[1]}"
  }
}

resource "equinix_fabric_routing_protocol" "metal_bgp" {
  depends_on = [equinix_fabric_routing_protocol.metal_direct]

  connection_uuid = module.cloud_router_2_metal_connection.primary_connection_id
  name            = "${local.name_prefix}-metal-bgp"
  type            = "BGP"

  customer_asn = var.metal_bgp_asn

  bgp_ipv4 {
    enabled          = true
    customer_peer_ip = local.metal_router_ip
  }
}

# --- FABRIC CONNECTION TO AWS ---

module "cloud_router_2_aws_connection" {
  source  = "equinix/fabric/equinix//modules/cloud-router-connection"
  version = "0.12.0"

  connection_name      = "${local.name_prefix}-aws"
  connection_type      = "IP_VC"
  notifications_type   = "ALL"
  notifications_emails = var.notifications_emails
  project_id           = var.fabric_project_id
  bandwidth            = var.fabric_aws_connection_speed

  #Aside config
  aside_fcr_uuid = equinix_fabric_cloud_router.this.id

  #Zside config
  zside_ap_authentication_key = var.aws_account_id
  zside_seller_region         = var.aws_region
  zside_location              = var.metro_code
  zside_fabric_sp_name        = var.fabric_aws_service_profile
}

data "equinix_fabric_connection" "aws" {
  depends_on = [module.cloud_router_2_aws_connection]
  uuid       = module.cloud_router_2_aws_connection.primary_connection_id
}

resource "equinix_fabric_routing_protocol" "aws_direct" {
  connection_uuid = module.cloud_router_2_aws_connection.primary_connection_id
  name            = "${local.name_prefix}-aws-direct"
  type            = "DIRECT"

  direct_ipv4 {
    equinix_iface_ip = aws_dx_private_virtual_interface.this.customer_address
  }
}

resource "equinix_fabric_routing_protocol" "aws_bgp" {
  depends_on = [equinix_fabric_routing_protocol.aws_direct]

  connection_uuid = module.cloud_router_2_aws_connection.primary_connection_id
  name            = "${local.name_prefix}-aws-bgp"
  type            = "BGP"

  customer_asn = aws_dx_gateway.this.amazon_side_asn
  bgp_auth_key = aws_dx_private_virtual_interface.this.bgp_auth_key

  bgp_ipv4 {
    enabled          = true
    customer_peer_ip = split("/", aws_dx_private_virtual_interface.this.amazon_address)[0]
  }
}