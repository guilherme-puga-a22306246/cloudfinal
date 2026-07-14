# Disaster Recovery Runbook

## Overview

This project implements an automated **Warm Standby Disaster Recovery architecture** on AWS using:

- Terraform
- GitHub Actions
- Amazon Route 53 Failover Routing
- Amazon RDS Cross-Region Read Replication
- AWS Systems Manager Parameter Store (SSM)
- Ansible

The solution provides automated disaster recovery while maintaining infrastructure consistency after failover. The deployment automatically adapts to whichever AWS region is currently marked as active.

---

# Architecture

## Active Region

Contains:

- EC2 Instance
- Application Load Balancer
- Amazon RDS PostgreSQL Primary (Multi-AZ)
- Amazon SQS

## Passive Region

Contains:

- EC2 Instance
- Application Load Balancer
- Amazon RDS Cross-Region Read Replica
- Amazon SQS

Traffic is managed through Amazon Route 53 Failover Routing.

Unlike the initial implementation, the active region is no longer fixed. Instead, the active/passive roles are dynamically stored in AWS Systems Manager Parameter Store.

---

# DR State Management

The Disaster Recovery state is stored in AWS Systems Manager Parameter Store.

Parameters:

```
/cloud-final/dr/active-region
/cloud-final/dr/passive-region
/cloud-final/dr/status
```

Possible states:

```
healthy
failing-over
failed-over
rebuilding
```

This allows every workflow and Terraform deployment to determine the current topology automatically.

---

# Infrastructure Provisioning

Infrastructure is fully provisioned using Terraform.

Modules:

- app_environment
- vpc
- ec2
- alb
- rds
- sqs
- route53

The Route 53 Terraform module automatically reads the active region from SSM Parameter Store and assigns:

- PRIMARY Route 53 record
- SECONDARY Route 53 record

This removes the need to manually modify Terraform after every disaster recovery event.

---

# CI/CD

Deployment is fully automated through GitHub Actions.

Deployment Pipeline:

1. Checkout repository
2. Authenticate to AWS using OIDC
3. Terraform Init
4. Terraform Validate
5. Terraform Plan
6. Terraform Apply
7. Export Terraform Outputs
8. Generate Ansible Inventory
9. Deploy services using Ansible

The deployment pipeline automatically deploys according to the region currently marked as active.

---

# Health Monitoring

Amazon Route 53 continuously monitors:

```
http://cloud.guilhermepuga.pt/actuator/health
```

Configuration:

- Protocol: HTTP
- Interval: 30 seconds
- Failure Threshold: 3

If the active environment becomes unavailable, Route 53 automatically redirects traffic to the standby environment.

No manual DNS changes are required.

---

# Disaster Recovery Workflows

## 1. DR Failover Drill

Purpose:

Simulate a disaster without permanently changing the production topology.

Operations:

- Stop the active EC2 instance
- Wait for Route 53 automatic failover
- Validate application health
- Restart the original EC2 instance

This workflow validates the failover mechanism without modifying the database topology.

---

## 2. DR Promote Standby

Purpose:

Promote the standby environment to become the new production environment.

Operations:

- Promote the RDS Read Replica
- Wait for promotion completion
- Update Route 53 failover records
- Update SSM Parameter Store
- Mark DR state as:

```
failed-over
```

After this workflow completes:

- The standby region becomes the new production environment.
- Route 53 routes all traffic to the new region.
- Terraform deployments automatically adapt to the new active region.

---

## 3. DR Rebuild Former Primary

Purpose:

Restore the former primary region as the new standby environment.

Operations:

- Remove the previous primary database
- Create a new Cross-Region Read Replica
- Wait for replication
- Validate replica health
- Update DR state to:

```
healthy
```

At the end of this workflow, the architecture returns to a fully operational Warm Standby configuration.

---

# Disaster Recovery Flow

```
Healthy
   │
   ▼
Failover Drill (optional)
   │
   ▼
Promote Standby
   │
   ▼
Application running in new region
   │
   ▼
Rebuild Former Primary
   │
   ▼
Healthy
```

---

# Recovery Objectives

## Recovery Time Objective (RTO)

Recovery time consists of:

- Route 53 failure detection
- DNS failover propagation
- RDS Read Replica promotion

Expected RTO:

average of 131 seconds (2 minutes and 11 seconds)

---

## Recovery Point Objective (RPO)

Database protection is provided through:

- Amazon RDS Multi-AZ
- Amazon RDS Cross-Region Read Replica
- Automated backups
- Continuous asynchronous replication

Expected RPO:

Seconds to a few minutes depending on replication lag.

---

# Cost Strategy

This solution implements a Warm Standby architecture.

Resources running permanently:

- Standby EC2
- Standby ALB
- Standby RDS Read Replica
- Standby SQS

Advantages:

- Low Recovery Time
- Minimal operational intervention
- Automatic DNS failover
- Fast infrastructure recovery

Trade-off:

Higher infrastructure cost compared to a Pilot Light architecture.

---

# Validation Checklist

- Terraform provisions both environments.
- GitHub Actions successfully deploys both environments.
- Route 53 Failover Routing configured.
- Route 53 Health Checks operational.
- Multi-AZ database enabled.
- Cross-Region Read Replica configured.
- Standby environment reachable.
- Automatic failover validated.
- Standby promotion validated.
- Former primary rebuilt successfully.
- SSM Parameter Store updated automatically.
- Infrastructure restored to Healthy state.

---

# Repository Structure

```text
.github/
└── workflows/
    ├── deploy.yml
    ├── dr-failover-drill.yml
    ├── dr-promote-standby.yml
    └── dr-rebuild-former-primary.yml

ansible/

infrastructure/
└── terraform/
    └── modules/
        ├── app_environment/
        ├── alb/
        ├── ec2/
        ├── route53/
        ├── rds/
        ├── sqs/
        └── vpc/

docs/
└── dr.md
```