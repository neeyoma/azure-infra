# Azure Web Application Infrastructure

This Terraform configuration deploys a secure, scalable web application infrastructure in Azure with three-tier architecture: web tier, application tier, and database tier.

## Architecture Overview

The infrastructure consists of:

- **Web Tier**: Virtual Machine Scale Set (VMSS) with Ubuntu 20.04 LTS in WebSubnet
- **Application Tier**: Azure App Service in AppSubnet
- **Database Tier**: Azure SQL Database with private endpoint in DBSubnet
- **Security**: Network Security Groups (NSGs) and Azure Key Vault for secrets management
- **Networking**: Single VNet with three subnets and load balancer
- **Scalability**: Auto-scaling configured for VMSS based on CPU usage

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Terraform** (>= 1.0) installed
3. **Azure subscription** with appropriate permissions
4. **Service Principal** or **User Account** with Contributor and Key Vault Administrator roles

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd azure-infra
```

### 2. Configure Variables

Copy the example variables file and customize as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
resource_group_name = "rg-webapp-prod"
location           = "East US"
admin_username     = "azureuser"
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Validate
terraform validate

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Your Infrastructure

After deployment, Terraform will output key information:

```bash
# View outputs
terraform output

# Get the public IP of the load balancer
terraform output vmss_public_ip

# Get the App Service URL
terraform output app_service_url
```

## Infrastructure Components

### Networking

- **VNet**: `10.0.0.0/16` address space
- **WebSubnet**: `10.0.1.0/24` - Hosts VMSS instances
- **AppSubnet**: `10.0.2.0/24` - Hosts App Service
- **DBSubnet**: `10.0.3.0/24` - Hosts SQL Database private endpoint

### Security

#### Network Security Groups (NSGs)

**Web Subnet NSG**:
- Allow HTTP (80) and HTTPS (443) from internet
- Allow SSH (22) for management
- Deny all other inbound traffic

**App Subnet NSG**:
- Allow traffic from WebSubnet on port 8080
- Allow HTTP/HTTPS for App Service
- Deny all other inbound traffic

**Database Subnet NSG**:
- Allow traffic from AppSubnet on port 1433 (SQL Server)
- Deny all other inbound traffic

### Compute Resources

#### Virtual Machine Scale Set (VMSS)

- **SKU**: Standard_B2s
- **OS**: Ubuntu 20.04 LTS
- **Instances**: 2-5 (auto-scaling based on CPU)
- **Load Balancer**: Standard SKU with public IP
- **Auto-scaling**: Scale out at 75% CPU, scale in at 25% CPU

#### Azure App Service

- **SKU**: P1v2 (Premium)
- **OS**: Linux
- **Runtime**: Node.js 18 LTS
- **VNet Integration**: Connected to AppSubnet

#### Azure SQL Database

- **SKU**: S1 (Standard)
- **Size**: 20 GB
- **Access**: Private endpoint only
- **DNS**: Private DNS zone for name resolution

## Security Features

### Network Security

1. **Network Segmentation**: Three separate subnets with controlled traffic flow
2. **NSG Rules**: Restrictive rules allowing only necessary traffic
3. **Private Endpoints**: SQL Database accessible only from within the VNet
4. **No Public Access**: SQL Server has public network access disabled

### Identity and Access Management

1. **Key Vault**: Centralized secret management
2. **Managed Identity**: Where applicable for service-to-service authentication

### Data Protection

1. **Encryption**: All data encrypted at rest and in transit
2. **Private DNS**: Internal name resolution for private endpoints
3. **Network Isolation**: Database tier isolated from direct internet access

## Scalability Features

### Auto-scaling

- **VMSS Auto-scaling**: Based on CPU utilization
- **Minimum Instances**: 2
- **Maximum Instances**: 5
- **Scale Out Threshold**: 75% CPU over 10 minutes
- **Scale In Threshold**: 25% CPU over 10 minutes

### Performance

- **Load Balancer**: Distributes traffic across VMSS instances
- **Premium Storage**: SSD storage for optimal performance
- **App Service Premium**: Dedicated compute resources

## Monitoring and Maintenance

### Outputs

The configuration provides these important outputs:

- **vmss_public_ip**: Public IP address for web access
- **app_service_url**: Direct URL to the App Service
- **sql_private_endpoint_fqdn**: Private FQDN for SQL Database

### Access Management

1. **VMSS Access**: Use SSH key stored in Key Vault
2. **App Service**: Access via VNet integration or public URL
3. **SQL Database**: Access only via private endpoint from AppSubnet

## Customization

### Modifying Configuration

The infrastructure is modular and can be customized:

1. **Scaling**: Adjust VMSS instance counts and auto-scaling thresholds
2. **SKUs**: Modify VM sizes and App Service plans
3. **Network**: Change CIDR ranges and subnet configurations
4. **Security**: Add additional NSG rules or modify existing ones


## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Ensure you have backups of any important data.

## Support

For issues or questions:

1. Check the [Terraform Azure Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
2. Review Azure service-specific documentation
3. Check the troubleshooting section above

## License

This project is licensed under the MIT License - see the LICENSE file for details.
