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

  // Direct Connect ID
  aws_dx_connection_id = [
    for z in data.equinix_fabric_connection.aws.z_side : [
      for ap in z.access_point : ap.provider_connection_id
    ][0]
  ][0]

  // Direct Virtual Interface VXLAN
  aws_dx_vif_vlan = [
    for z in data.equinix_fabric_connection.aws.z_side : [
      for ap in z.access_point : [
        for lp in ap.link_protocol : lp.vlan_tag
      ][0]
    ][0]
  ][0]
}
