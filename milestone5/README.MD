# Milestone 5: PowerShell Automation

This milestone implements PowerShell scripting for automated file generation with random 20-digit numbers, including both a local execution script and a function scheduled to run on the Function App.

## Implementation Approach

The implementation follows professional DevOps best practices by:

1. **Using Remote State** - References only the necessary resources from Milestone 1
2. **Flexible Design** - Works with any Function App configuration (public or private)
3. **Script Generation** - Creates ready-to-use PowerShell scripts
4. **Deployment Automation** - Provides deployment scripts for both Unix and Windows
5. **Complete Documentation** - Includes usage instructions and testing guidance

## Resources and Files Created

1. **Storage Container**
    - Container for storing the generated files

2. **PowerShell Scripts**
    - `Generate-RandomNumberFile.ps1` - For execution from your laptop
    - `ScheduledRandomNumber/run.ps1` - For execution in the Function App
    - `test_local_script.ps1` - For testing the local script
    - `deploy_function.sh` and `deploy_function.ps1` - For deploying the function

3. **Function Configuration**
    - `function.json` - Timer trigger with CRON schedule (every 6 hours at the 30 minute mark on Mon, Wed, Fri)
    - `host.json` - Function App host configuration

4. **Deployment Package**
    - ZIP file containing all function files ready for deployment

## Functionality

1. **Local PowerShell Script**
    - Takes parameters for Storage Account name, Resource Group, etc.
    - Generates a random 20-digit number
    - Creates a file with the number
    - Uploads the file to the specified Storage Account container

2. **Function App Script**
    - Scheduled to run every 6 hours at the 30-minute mark on Monday, Wednesday, and Friday
    - Uses managed identity or connection string for authentication
    - Generates a random 20-digit number
    - Creates a file in the Storage Account container

## Deployment Instructions

1. Initialize Terraform with the backend configuration:
   ```bash
   cd milestone5
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

4. After applying the Terraform configuration, you'll have:
    - A local PowerShell script you can run from your laptop
    - A function ZIP file ready for deployment
    - Deployment scripts for both Bash and PowerShell

5. To test the local script:
   ```powershell
   # On Windows
   .\test_local_script.ps1
   ```

6. To deploy the function to the Function App:
   ```bash
   # On Unix/Linux/Mac
   chmod +x ./deploy_function.sh
   ./deploy_function.sh
   
   # On Windows
   .\deploy_function.ps1
   ```

## Validation

After deployment, you can validate the implementation by:

1. **Testing the local script**:
    - Run the test script as described above
    - Check the Storage Account container for the generated file

2. **Verifying the function deployment**:
    - Check the Function App in the Azure Portal
    - Verify the function appears with the correct schedule
    - Manually trigger the function to test it
    - Check the logs to confirm successful execution

3. **Confirming the schedule**:
    - The function is configured to run at 3:30, 9:30, 15:30, and 21:30 UTC on Mondays, Wednesdays, and Fridays

## Best Practices Implemented

- **Error Handling** - Comprehensive error handling in all scripts
- **Documentation** - Thorough inline documentation with parameter descriptions
- **Secure Authentication** - Support for managed identities and connection strings
- **Idempotent Operations** - Scripts check if resources exist before creating them
- **Logging** - Detailed logging of operations and errors
- **Cross-Platform Support** - Deployment scripts for both Unix and Windows