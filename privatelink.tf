# --- AWS PRIVATELINK ---

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }
}

resource "aws_vpc_endpoint" "this" {
  vpc_id            = aws_default_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Interface"

  subnet_ids = [data.aws_subnets.this.ids[0]]

  private_dns_enabled = false
  security_group_ids  = [aws_security_group.this.id]
}

resource "aws_security_group" "this" {
  name_prefix = local.name_prefix
  vpc_id      = aws_default_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.metal_bgp_peer_subnet]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
