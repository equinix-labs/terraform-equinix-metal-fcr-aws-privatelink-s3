# --- EQUINIX METAL ---

# allocate metro vlans for the project 
resource "equinix_metal_vlan" "this" {
  description = "${local.name_prefix} metro VLAN"
  metro       = var.metro_code
  project_id  = var.metal_project_id
}

# order shared connection
resource "equinix_metal_connection" "this" {
  name          = local.name_prefix
  project_id    = var.metal_project_id
  metro         = var.metro_code
  redundancy    = "primary"
  speed         = format("%dMbps", var.fabric_metal_connection_speed)
  type          = "shared_port_vlan"
  contact_email = var.notifications_emails[0]

  vlans = [
    equinix_metal_vlan.this.vxlan
  ]
}

# create a temporary SSH key pairs for the project
module "ssh" {
  source     = "./modules/metal_ssh/"
  project_id = var.metal_project_id
}

# create metal node
resource "equinix_metal_device" "this" {
  hostname         = local.name_prefix
  plan             = var.metal_plan
  metro            = var.metro_code
  operating_system = var.metal_operating_system
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id

  user_data = templatefile("${path.module}/templates/metal-userdata.tmpl", {
    metal_vlan_id        = equinix_metal_vlan.this.vxlan,
    metal_router_ip      = local.metal_router_ip,
    metal_router_netmask = local.metal_router_netmask,
    metal_router_asn     = var.metal_bgp_asn
    fabric_router_ip     = local.fabric_router_ip,
    fabric_router_asn    = equinix_fabric_cloud_router.this.equinix_asn
  })
}

# put metal nodes in hybrid bonded mode and attach metro vlan to the nodes
resource "equinix_metal_port" "port" {
  port_id    = [for p in equinix_metal_device.this.ports : p.id if p.name == "bond0"][0]
  layer2     = false
  bonded     = true
  vxlan_ids  = [equinix_metal_vlan.this.vxlan]
  depends_on = [equinix_metal_device.this]
}
