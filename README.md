# Azure Function App Secure Deployment Project

## Project Overview

This project demonstrates a comprehensive implementation of a secure Azure Function App deployment with advanced features including:

- Secure deployment with Key Vault integration
- Comprehensive monitoring and logging setup
- Storage account auditing
- Network isolation through private endpoints
- PowerShell automation for file generation

The implementation follows Azure best practices and security recommendations throughout all stages of the deployment.

## Milestones

### Milestone 1: Secure Function App Deployment with Key Vault Integration

Established a secure foundation for the Function App with proper secret management:

- Created secure Azure Function App with Application Insights integration
- Configured Key Vault with proper access policies
- Stored sensitive configuration in Key Vault
- Implemented managed identity for secure secrets access
- Applied RBAC permissions following principle of least privilege

### Milestone 2: Monitoring Configuration with Application Insights and Log Analytics

Set up comprehensive monitoring for operational visibility:

- Configured Application Insights for the Function App
- Set up Log Analytics workspace for centralized logging
- Created custom KQL queries for operational monitoring
- Implemented alerting for critical metrics
- Established diagnostic settings for comprehensive logging

### Milestone 3: Storage Account Auditing with KQL Queries

Implemented storage security with audit capabilities:

- Configured Storage Account with proper security settings
- Created advanced KQL queries for storage activity monitoring
- Set up audit trails for all storage operations
- Implemented automated reporting for security events
- Established baseline access patterns for anomaly detection

### Milestone 4: Network Isolation with Private Endpoints

Secured the Function App through network isolation:

- Deployed Function App on a private network
- Disabled public access to the Function App
- Created a Web App on a separate subnet
- Configured network rules to allow controlled access
- Validated connectivity through the Web App's development tools
- Implemented all resources and configurations via Infrastructure as Code

### Milestone 5: PowerShell Automation

Automated operational tasks through PowerShell:

- Created PowerShell scripts for generating random number files
- Implemented Azure Function to execute scheduled tasks
- Configured blob storage integration for file storage
- Set up proper error handling and logging
- Implemented secure credential management

## Infrastructure as Code

All resources are deployed using Infrastructure as Code (IaC) principles:

- Terraform for core infrastructure deployment
- ARM templates for specific Azure resources
- PowerShell scripts for automation and configuration

## Repository Structure

```
├── milestone1/
│   ├── terraform/              # Terraform files for Function App and Key Vault
│   ├── scripts/                # Setup and configuration scripts
│   └── docs/                   # Documentation specific to Milestone 1
├── milestone2/
│   ├── terraform/              # Terraform files for monitoring configuration
│   ├── queries/                # KQL queries for monitoring
│   └── docs/                   # Documentation specific to Milestone 2
├── milestone3/
│   ├── terraform/              # Terraform files for storage account setup
│   ├── queries/                # KQL queries for storage auditing
│   └── docs/                   # Documentation specific to Milestone 3
├── milestone4/
│   ├── terraform/              # Terraform files for network isolation
│   ├── diagrams/               # Network architecture diagrams
│   └── docs/                   # Documentation specific to Milestone 4
├── milestone5/
│   ├── powershell/             # PowerShell automation scripts
│   ├── function/               # Function App code
│   └── docs/                   # Documentation specific to Milestone 5
├── docs/                       # General project documentation
│   ├── Deployment.md           # Deployment instructions
│   └── TaskDescription.md      # Detailed task description
└── README.md                   # This file
```

## Getting Started

See [Deployment.md](docs/Deployment.md) for detailed deployment instructions for each milestone.

## Resource Naming Convention

All resources use a consistent naming convention with a unique suffix to ensure uniqueness:
- Resources deployed in West Europe region
- Using suffix "n2cte9" for resource names
- Examples:
  - Storage account: `funcsan2cte9`
  - Function app: `secure-func-n2cte9`
  - Key vault: `func-kv-n2cte9`
