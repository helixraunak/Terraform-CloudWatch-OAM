

variable "aws_accounts" {
  description = "List of target AWS account IDs"
  type        = list(string)
  default     = ["637423358261", "654654612410"]  # Order matters: first for account1, second for account2.
}

variable "environments" {
  description = "List of environments to deploy dashboards (e.g., Prod, NonProd). Enter one or both."
  type        = list(string)
  default     = ["NonProd"]  # Change to ["Prod", "NonProd"] to deploy for both.
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "metrics" {
  description = "List of EC2 metric names to monitor"
  type        = list(string)
  default     = [
    "CPUUtilization",
    "NetworkIn",
    "NetworkOut",
    "DiskReadOps",
    "DiskWriteOps",
    "DiskReadBytes",
    "DiskWriteBytes",
    "StatusCheckFailed",
    "StatusCheckFailed_Instance",
    "StatusCheckFailed_System"
  ]
}

