# Milestone 4: Network Isolation

This milestone implements network isolation for the Function App, ensuring it's only accessible through a private network. It also creates a Web App with the necessary network configuration to access the private Function App.

## Implementation Approach

The implementation follows professional DevOps best practices by:

1. **Using Remote State** - References resources from previous milestones through Terraform remote state
2. **Virtual Network Isolation** - Configures private networking for the Function App
3. **Private Endpoints** - Restricts Function App access to only the private network
4. **VNet Integration** - Enables the Web App to communicate with the private Function App
5. **Subnet Isolation** - Places the Web App on a separate network/subnet from the Function App
6. **Validation Tools** - Provides test pages and scripts to validate the network connectivity

## Resources Added

1. **Virtual Networks**
    - VNet for Function App
    - VNet for Web App
    - VNet peering between the two networks

2. **Network Security**
    - NSGs for both subnets
    - IP restrictions on the Function App
    - Private DNS zone for name resolution

3. **Compute Resources**
    - Premium Function App (replacing the consumption plan)
    - Web App with VNet integration
    - Private endpoint for the Function App

4. **Testing Tools**
    - Test HTML page for validating connectivity
    - Deployment script for the Web App

## Architecture Design

The network architecture follows these principles:

1. The Function App is placed in a private subnet with no public access
2. The Web App is in a separate subnet with public access
3. VNet peering allows communication between the subnets
4. Network security groups restrict traffic to only what's necessary
5. Private DNS zones enable name resolution for private endpoints
6. The Web App can reach the private Function App, but no other public traffic can

## Deployment Instructions

1. Initialize Terraform with the backend configuration:
   ```bash
   cd milestone4
   terraform init -backend-config=backend.conf
   ```

2. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

3. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

4. Deploy the test page to validate connectivity:
   ```bash
   chmod +x ./deploy_webapp.sh
   ./deploy_webapp.sh
   ```

## Validation

After deployment, you can validate the network isolation by:

1. **Verify the Function App is private**:
    - Attempt to access the Function App directly from your browser
    - You should not be able to reach it, as it's now private

2. **Verify the Web App can access the Function App**:
    - Visit the Web App URL
    - Click the "Test Connection" button
    - The Web App should be able to successfully communicate with the private Function App

3. **Check network configurations**:
    - Verify private endpoints are correctly established
    - Confirm NSG rules are properly configured
    - Check VNet peering is set up and working

## Best Practices Implemented

- **Network Isolation** - Function App is not accessible from the public internet
- **Least Privilege** - NSG rules restrict traffic to only what's needed
- **Private Networking** - All sensitive resources are placed behind private endpoints
- **Service Endpoints** - Secure connections to other Azure services
- **DNS Integration** - Private DNS zones for proper name resolution
- **Testing Automation** - Scripts to validate the network configuration