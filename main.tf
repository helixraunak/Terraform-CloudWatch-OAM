


# ##############################
# # Providers for Target Accounts
# ##############################

provider "aws" {
  alias  = "account1"
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_accounts[0]}:role/TerraformDeploymentRole"
    session_name = "TerraformDeploymentSession"
  }
}

provider "aws" {
  alias  = "account2"
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_accounts[1]}:role/TerraformDeploymentRole"
    session_name = "TerraformDeploymentSession"
  }
}

##############################
# Data Sources: Fetch EC2 instances per environment for each account
##############################

data "aws_instances" "instances_account1" {
  provider = aws.account1
  for_each = toset(var.environments)
  filter {
    name   = "tag:Environment"
    values = [each.key]
  }
}

data "aws_instances" "instances_account2" {
  provider = aws.account2
  for_each = toset(var.environments)
  filter {
    name   = "tag:Environment"
    values = [each.key]
  }
}

##############################
# Locals: Build Dashboard Configurations for each account
##############################

locals {
  dashboard_configs_account1 = flatten([
    for env in var.environments : [
      for metric in var.metrics : {
        environment    = env,
        metric         = metric,
        dashboard_name = "EC2-${env}-${var.aws_accounts[0]}-${metric}"
      }
    ]
  ])

  dashboard_configs_account2 = flatten([
    for env in var.environments : [
      for metric in var.metrics : {
        environment    = env,
        metric         = metric,
        dashboard_name = "EC2-${env}-${var.aws_accounts[1]}-${metric}"
      }
    ]
  ])
}

##############################
# CloudWatch Dashboards for Account 1
##############################

resource "aws_cloudwatch_dashboard" "dashboards_account1" {
  for_each = { for cfg in local.dashboard_configs_account1 : "${cfg.environment}_${cfg.metric}" => cfg }
  provider = aws.account1
  dashboard_name = each.value.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 6,
        height = 6,
        properties = {
          metrics = [
            [
              "AWS/EC2",
              each.value.metric,
              "InstanceId",
              join("\", \"", data.aws_instances.instances_account1[each.value.environment].ids)
            ]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region,
          title  = "EC2 ${each.value.metric} (${each.value.environment})"
        }
      }
    ]
  })
}

##############################
# CloudWatch Dashboards for Account 2
##############################

resource "aws_cloudwatch_dashboard" "dashboards_account2" {
  for_each = { for cfg in local.dashboard_configs_account2 : "${cfg.environment}_${cfg.metric}" => cfg }
  provider = aws.account2
  dashboard_name = each.value.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 6,
        height = 6,
        properties = {
          metrics = [
            [
              "AWS/EC2",
              each.value.metric,
              "InstanceId",
              join("\", \"", data.aws_instances.instances_account2[each.value.environment].ids)
            ]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region,
          title  = "EC2 ${each.value.metric} (${each.value.environment})"
        }
      }
    ]
  })
}

