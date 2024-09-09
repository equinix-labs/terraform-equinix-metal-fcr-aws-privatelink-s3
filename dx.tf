# --- AWS DIRECT CONNECT ---

locals {
  aws_dx_connection_id = [
    for z in data.equinix_fabric_connection.aws.z_side : [
      for ap in z.access_point : ap.provider_connection_id
    ][0]
  ][0]

  aws_dx_vif_vlan = [
    for z in data.equinix_fabric_connection.aws.z_side : [
      for ap in z.access_point : [
        for lp in ap.link_protocol : lp.vlan_tag
      ][0]
    ][0]
  ][0]
}

resource "aws_dx_connection_confirmation" "this" {
  connection_id = local.aws_dx_connection_id
}

resource "aws_dx_gateway" "this" {
  depends_on = [aws_dx_connection_confirmation.this]

  name            = local.name_prefix
  amazon_side_asn = "64512" // default Amazon ASN
}

resource "aws_dx_private_virtual_interface" "this" {
  connection_id  = local.aws_dx_connection_id
  name           = local.name_prefix
  vlan           = local.aws_dx_vif_vlan
  address_family = "ipv4"
  bgp_asn        = equinix_fabric_cloud_router.this.equinix_asn
  dx_gateway_id  = aws_dx_gateway.this.id
}

resource "aws_default_vpc" "this" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_vpn_gateway" "this" {
  vpc_id = aws_default_vpc.this.id

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_vpn_gateway_route_propagation" "this" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = aws_default_vpc.this.default_route_table_id
}

resource "aws_dx_gateway_association" "this" {
  dx_gateway_id         = aws_dx_gateway.this.id
  associated_gateway_id = aws_vpn_gateway.this.id
}


