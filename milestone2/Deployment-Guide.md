# Milestone 2 Deployment Steps

This guide provides step-by-step instructions for deploying Milestone 2 that uses remote state to reference Milestone 1 resources. 

## Files Provided

- **provider.tf** - Provider configuration
- **remote_state.tf** - References Milestone 1 state
- **main.tf** - Monitoring resources implementation
- **variables.tf** - Milestone 2 specific variables
- **outputs.tf** - Outputs from both Milestone 1 and 2
- **terraform.tfvars** - Variable values
- **backend.conf** - Backend configuration
- **README.md** - Documentation

## Deployment Instructions

1. Make sure all the files above are in your milestone2 directory
2. Initialize Terraform with the backend configuration:
   ```bash
   cd milestone2
   terraform init -backend-config=backend.conf
   ```

3. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

4. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

## What This Approach Achieves

- **Clean Separation** - Milestone 2 code focuses only on monitoring
- **No Duplication** - Resources from Milestone 1 are referenced, not recreated
- **Maintainability** - When you move to Milestone 3, you can follow the same pattern
- **Professional Structure** - Follows DevOps best practices for infrastructure code
