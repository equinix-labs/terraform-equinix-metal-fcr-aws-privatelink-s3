# Resource name prefix
resource "random_string" "name_prefix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  name_prefix          = "demoday-${random_string.name_prefix.result}"
  metal_router_ip      = cidrhost(var.metal_bgp_peer_subnet, 0)
  metal_router_netmask = cidrnetmask(cidrsubnet(var.metal_bgp_peer_subnet, -1, -1))
  fabric_router_ip     = cidrhost(var.metal_bgp_peer_subnet, 1)
}
