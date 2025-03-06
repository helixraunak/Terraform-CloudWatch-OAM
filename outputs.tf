

output "dashboard_urls" {
  description = "CloudWatch Dashboard URLs"
  value = flatten([
    [
      for dash in aws_cloudwatch_dashboard.dashboards_account1 :
      "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${dash.dashboard_name}"
    ],
    [
      for dash in aws_cloudwatch_dashboard.dashboards_account2 :
      "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${dash.dashboard_name}"
    ]
  ])
}

# output "dashboard_url" {
#   description = "URL of the unified CloudWatch Dashboard"
#   value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.unified.dashboard_name}"
# }

