# Variables specific to Milestone 5

variable "blob_container_name" {
  description = "Name of the blob container to store generated files"
  type        = string
  default     = "generated-files"
}

variable "cron_expression" {
  description = "CRON expression for the scheduled function (every 6 hours at 30 minutes past the hour on Monday, Wednesday, Friday)"
  type        = string
  default     = "0 30 3,9,15,21 * * 1,3,5"
}

variable "powershell_script_name" {
  description = "Name of the PowerShell script file"
  type        = string
  default     = "Generate-RandomNumberFile.ps1"
}

variable "function_name" {
  description = "Name of the function to create in the Function App"
  type        = string
  default     = "ScheduledRandomNumber"
}