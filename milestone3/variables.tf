# Variables specific to Milestone 3

variable "log_retention_days" {
  description = "Number of days to retain diagnostic logs"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 7 and 730."
  }
}

variable "test_blob_count" {
  description = "Number of test blobs to create for audit testing"
  type        = number
  default     = 1
  validation {
    condition     = var.test_blob_count >= 0 && var.test_blob_count <= 10
    error_message = "Test blob count must be between 0 and 10."
  }
}