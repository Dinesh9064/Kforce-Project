# Git Repository Structure

Below is the recommended folder structure for your Azure Function App Secure Deployment project. This structure organizes the codebase by milestone and resource type, making it easy for the interviewer to navigate and understand your implementation.

```
azure-function-secure-deployment/
├── .github/                    # GitHub-specific files
│   └── workflows/              # GitHub Actions workflows for CI/CD
│       └── validate.yml        # Validation workflow
├── milestone1/                 # Milestone 1: Secure Function App with Key Vault
│   ├── terraform/              # Terraform files for Milestone 1
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Input variables
│   │   ├── outputs.tf         # Output variables
│   │   └── provider.tf        # Provider configuration
│   ├── scripts/                # Helper scripts
│   │   └── verify-deployment.sh # Verification script
│   └── docs/                   # Documentation specific to Milestone 1
│       └── key-vault-setup.md  # Key Vault configuration details
├── milestone2/                 # Milestone 2: Monitoring Configuration
│   ├── terraform/              # Terraform files for Milestone 2
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Input variables
│   │   ├── outputs.tf         # Output variables
│   │   └── provider.tf        # Provider configuration
│   ├── queries/                # KQL queries
│   │   ├── function-logs.kql  # Function app log queries
│   │   └── alerts.kql         # Alert queries
│   └── docs/                   # Documentation specific to Milestone 2
│       └── monitoring-setup.md # Monitoring configuration details
├── milestone3/                 # Milestone 3: Storage Account Auditing
│   ├── terraform/              # Terraform files for Milestone 3
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Input variables
│   │   ├── outputs.tf         # Output variables
│   │   └── provider.tf        # Provider configuration
│   ├── queries/                # KQL queries for storage auditing
│   │   ├── storage-audit.kql  # Storage audit queries
│   │   └── security-events.kql # Security event queries
│   └── docs/                   # Documentation specific to Milestone 3
│       └── storage-security.md # Storage security details
├── milestone4/                 # Milestone 4: Network Isolation
│   ├── terraform/              # Terraform files for Milestone 4
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Input variables
│   │   ├── outputs.tf         # Output variables
│   │   └── provider.tf        # Provider configuration
│   ├── diagrams/               # Network architecture diagrams
│   │   └── network-design.png # Network design diagram
│   └── docs/                   # Documentation specific to Milestone 4
│       └── network-setup.md    # Network configuration details
├── milestone5/                 # Milestone 5: PowerShell Automation
│   ├── terraform/              # Terraform files for Milestone 5
│   │   ├── main.tf            # Main Terraform configuration
│   │   ├── variables.tf       # Input variables
│   │   ├── outputs.tf         # Output variables
│   │   └── provider.tf        # Provider configuration
│   ├── powershell/             # PowerShell scripts
│   │   ├── Generate-RandomNumberFile.ps1 # Main script
│   │   └── test_local_script.ps1 # Test script
│   ├── function/               # Function App code
│   │   ├── ScheduledRandomNumber/ # Function directory
│   │   │   ├── function.json   # Function configuration
│   │   │   └── run.ps1         # Function code
│   │   ├── host.json           # Host configuration
│   │   └── profile.ps1         # PowerShell profile
│   └── docs/                   # Documentation specific to Milestone 5
│       └── automation-setup.md # Automation configuration details
├── modules/                    # Shared Terraform modules
│   ├── function-app/           # Function App module
│   ├── key-vault/              # Key Vault module
│   ├── storage/                # Storage module
│   └── network/                # Network module
├── scripts/                    # Project-wide scripts
│   ├── setup-env.sh            # Environment setup script
│   └── cleanup.sh              # Resource cleanup script
├── docs/                       # General project documentation
│   ├── Deployment.md           # Deployment instructions
│   └── TaskDescription.md      # Detailed task description
├── .gitignore                  # Git ignore file
├── README.md                   # Project README
└── LICENSE                     # Project license
```

## Usage Guidelines

1. **Initial Repository Setup**:

   ```bash
   # Create a new repository on GitHub
   # Then clone it locally
   git clone https://github.com/your-username/azure-function-secure-deployment.git
   cd azure-function-secure-deployment
   
   # Create the folder structure
   mkdir -p .github/workflows
   mkdir -p milestone{1..5}/{terraform,docs}
   mkdir -p milestone2/queries
   mkdir -p milestone3/queries
   mkdir -p milestone4/diagrams
   mkdir -p milestone5/{powershell,function/ScheduledRandomNumber}
   mkdir -p modules/{function-app,key-vault,storage,network}
   mkdir -p scripts
   mkdir -p docs
   
   # Copy your .gitignore file
   # Copy README.md, Deployment.md, and TaskDescription.md to the appropriate locations
   ```

2. **Adding Code to Repository**:

   ```bash
   # Add your existing files to the appropriate directories
   # For example, add Terraform files to milestone*/terraform/ directories
   # Add PowerShell scripts to milestone5/powershell/ directory
   
   # Add all files to git
   git add .
   
   # Commit the changes
   git commit -m "Initial commit with project structure and documentation"
   
   # Push to GitHub
   git push origin main
   ```

3. **Organizing by Milestone**:

   Place all files related to a specific milestone in its corresponding directory. This helps maintain a clean and organized repository structure.

4. **Shared Modules**:

   Use the `modules/` directory for any Terraform modules that are shared across multiple milestones. This promotes code reuse and consistency.

5. **Documentation**:

   Ensure each milestone has its specific documentation in the corresponding `docs/` directory, while keeping general project documentation in the root `docs/` directory.

## Best Practices for Git Repository

1. **Commit Regularly**: Make small, focused commits with clear commit messages.

2. **Use Branches**: Create feature branches for each milestone or significant change.

3. **Pull Requests**: Use pull requests for code reviews and milestone integration.

4. **Tag Releases**: Tag each milestone completion as a release (e.g., `v1.0-milestone1`).

5. **Protect Main Branch**: Configure branch protection rules for the main branch.

6. **CI/CD Integration**: Set up GitHub Actions for automated validation and testing.

7. **Secrets Management**: Never commit sensitive information. Use GitHub Secrets for CI/CD integration.

8. **README Updates**: Keep the README updated with the latest project status and instructions.
