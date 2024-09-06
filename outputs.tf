output "metal_device_public_ip" {
  value = equinix_metal_device.this.access_public_ipv4
}

output "metal_device_ssh_key" {
  value = module.ssh.ssh_private_key
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.this.bucket
}

output "aws_s3_endpoint_url" {
  value = replace(aws_vpc_endpoint.this.dns_entry[0].dns_name, "*", "https://bucket")
}



