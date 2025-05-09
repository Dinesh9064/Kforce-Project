# Milestone 2 specific variables

variable "app_insights_sampling_percentage" {
  description = "Application Insights sampling percentage (0-100)"
  type        = number
  default     = 100
  validation {
    condition     = var.app_insights_sampling_percentage >= 0 && var.app_insights_sampling_percentage <= 100
    error_message = "Application Insights sampling percentage must be between 0 and 100."
  }
}

variable "log_analytics_retention_days" {
  description = "Log Analytics Workspace data retention in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}