# Milestone 2: Azure Function App Monitoring Configuration

This milestone adds comprehensive monitoring capabilities to the secure Azure Function App deployed in Milestone 1. It implements Application Insights and Log Analytics Workspace integration with proper diagnostic settings for all resources.

## Implementation Approach

This implementation follows professional DevOps best practices by:

1. **Using Remote State** - References Milestone 1 resources through Terraform remote state
2. **Separate State Files** - Maintains a separate state file for better lifecycle management
3. **Clean and Focused Code** - Each milestone contains only the code relevant to its specific requirements
4. **No Resource Recreation** - Builds upon existing resources without disrupting them

## Resources Added

- **Log Analytics Workspace** - Central location for collecting and analyzing logs and metrics
- **Application Insights** - Application Performance Monitoring (APM) for the Function App
- **Diagnostic Settings** - For various resources to send logs and metrics to Log Analytics

## Deployment Instructions

1. Initialize Terraform with the backend configuration:
   ```bash
   cd milestone2
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

## Validation

After deployment, verify that:

1. Log Analytics Workspace has been created
2. Application Insights is properly configured
3. Function App has been updated with Application Insights settings
4. Diagnostic settings are enabled for all resources

You can check the Azure Portal or use the following Azure CLI commands:

```bash
# Check Application Insights
az monitor app-insights component show --app func-ai-n2cte9 -g milestones-we-dev

# Check Log Analytics Workspace
az monitor log-analytics workspace show --workspace-name func-law-n2cte9 -g milestones-we-dev

# Verify Function App settings
az functionapp config appsettings list --name secure-func-n2cte9 -g milestones-we-dev --query "[?name=='APPINSIGHTS_INSTRUMENTATIONKEY']"
```

## Best Practices Implemented

- **Remote State Pattern** - References existing resources without recreating them
- **Focused Implementation** - Clean separation between milestones for better maintainability
- **Consistent Naming** - Uses the same naming convention established in Milestone 1
- **Comprehensive Monitoring** - Full diagnostic settings for all resources
- **Infrastructure as Code** - Automated, repeatable deployment process