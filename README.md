# Terraform Demo: Private Interconnection between Equinix Metal and AWS S3 using Fabric Cloud Router (FCR) and AWS PrivateLink

## Overview

This demo showcases how to use Terraform to set up a private interconnection between Equinix Metal and AWS S3. The architecture involves a Metal device, a Fabric Cloud Router (FCR), two Fabric interconnections, and several AWS components including Direct Connect, a VPC with a subnet, PrivateLink, and an S3 bucket.

## Architecture Components

1. **Equinix Metal:**
   - Metal server for hosting the application
   - Metal VLAN

2. **Equinix Fabric:**
   - Fabric Cloud Router (FCR)
   - Two Fabric interconnections

3. **AWS:**
   - Direct Connect Gateway
   - Direct Connect Virtual Private Gateway
   - VPC endpoint for S3
   - S3 Bucket and Bucket Policy

## Prerequisites

- Terraform installed on your local machine
- AWS CLI configured with appropriate credentials
- Access to Equinix Metal and AWS accounts

## Setup Instructions

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/equinix-labs/terraform-equinix-metal-fcr-aws-privatelink-s3
   cd terraform-equinix-metal-fcr-aws-privatelink-s3
   ```

2. **Initialize Terraform:**
   ```sh
   terraform init
   ```

3. **Review Configuration Files:**

   - `main.tf` – Main configuration file
   - `metal.tf` – Equinix Metal device configuration
   - `fabric.tf` – Fabric interconnections setup
   - `dx.tf` – AWS Direct Connect configuration
   - `privatelink.tf` – AWS PrivateLink setup
   - `s3.tf` – S3 bucket setup
   - `outputs.tf` – Output values definitions
   - `variables.tf` – Variable definitions
   - `versions.tf` – Providers and version constraints

4. **Apply Terraform Configuration:**
   ```sh
   terraform apply
   ```

   Note: This may take approximately 20 minutes to complete.

5. **Post-Deployment Steps:**
   - Run `terraform outputs` to take the $aws_s3_bucket and $aws_s3_endpoint_url$ values
   - Connect to the Metal server and configure AWS credentials.
   - Test S3 connectivity before and after configuring the private link.

    ```sh
    echo "Hello Metal!" > demo.txt
    aws s3 cp demo.txt s3://{aws_s3_bucket} --endpoint-url {aws_s3_endpoint_url}
    aws s3 rm s3://{aws_s3_bucket}/demo.txt
    ```
## Clean Up

To clean up the resources created by this demo, run:
```sh
terraform destroy
```
