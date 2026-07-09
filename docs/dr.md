# Disaster Recovery Runbook

## Overview

This project implements an automated Disaster Recovery (DR) architecture on AWS using Infrastructure as Code (Terraform), CI/CD (GitHub Actions), Route 53 DNS failover and a warm standby deployment.

The objective is to ensure service continuity in the event of a failure affecting the primary deployment without requiring manual DNS changes.

---

# Architecture

## Primary Environment

- Availability Zone: eu-central-1a
- EC2
- Application Load Balancer
- Amazon RDS PostgreSQL (Multi-AZ)
- Amazon SQS

## Standby Environment

- Availability Zone: eu-central-1b
- EC2
- Application Load Balancer
- Amazon RDS Read Replica
- Amazon SQS

Traffic is routed through Amazon Route 53 using DNS failover.

---

# Disaster Recovery Strategy

This implementation follows a **Warm Standby** strategy.

The standby environment is permanently provisioned but only receives production traffic when the Route 53 health check detects that the primary environment is unavailable.

Advantages:

- Low Recovery Time Objective (RTO)
- Minimal operational intervention
- Infrastructure already provisioned
- Automated DNS failover

Trade-off:

- Higher infrastructure cost than Pilot Light
- Faster recovery

---

# Infrastructure Provisioning

All infrastructure is provisioned through Terraform.

Modules:

- app_environment
- vpc
- ec2
- alb
- rds
- sqs
- route53

The standby environment is created by reusing the same Terraform modules as the primary deployment using different parameters.

---

# CI/CD

Deployment is fully automated through GitHub Actions.

Pipeline:

1. Checkout repository
2. Authenticate to AWS using OIDC
3. Terraform Init
4. Terraform Validate
5. Terraform Plan
6. Terraform Apply
7. Export Terraform Outputs
8. Configure Ansible Inventory
9. Deploy application using Ansible

Both primary and standby environments are deployed from the same pipeline.

---

# Health Monitoring

Route 53 continuously checks:

```
http://cloud.guilhermepuga.pt/actuator/health
```

Health Check:

- Protocol: HTTP
- Interval: 30 seconds
- Failure Threshold: 3

If the primary endpoint becomes unhealthy, Route 53 automatically routes traffic to the standby environment.

No manual console interaction is required.

---

# Failover Procedure

## Simulating a failure

Stop the Primary EC2 instance.

Example:

```
aws ec2 stop-instances --instance-ids <PRIMARY_INSTANCE_ID>
```

---

## Expected behaviour

1. Primary health check fails.
2. Route 53 detects the failure.
3. DNS failover occurs automatically.
4. Requests are redirected to the standby Application Load Balancer.
5. Manually promote the standby RDS Read Replica to become the new primary database.

```bash
aws rds promote-read-replica --db-instance-identifier cloud-final-dev-standby-database --backup-retention-period 7 --region eu-central-1
  ```
6. wait for the promotion to complete (can take several minutes).
```bash
aws rds wait db-instance-available --db-instance-identifier cloud-final-dev-standby-database --region eu-central-1
```
7. Service remains available.

---

### Why manual promotion of the RDS Read Replica is required?

Automatic promotion was intentionally not implemented to avoid split-brain scenarios and unintended promotions caused by transient health-check failures or false positives.

# Rollback Procedure

Start the primary EC2 instance.

```
aws ec2 start-instances --instance-ids <PRIMARY_INSTANCE_ID>
```

Once the health check becomes healthy again, Route 53 automatically restores traffic to the primary deployment.

---

# Recovery Objectives

## Recovery Time Objective (RTO)

DNS failover + tempo de promoção da réplica

---

## Recovery Point Objective (RPO)

Database protection is provided through:

- Amazon RDS Multi-AZ
- Amazon RDS Read Replica
- Automated backups (7-day retention)
- Standby RDS promotion to primary 

Expected RPO:

Seconds/minutes, dependent on the replication lag

---

# Cost Strategy

This solution implements a Warm Standby architecture.

Resources running permanently:

- Standby EC2
- Standby ALB
- Standby RDS Replica

This increases operational cost compared to a Pilot Light solution but significantly reduces recovery time.

---

# Validation Checklist

- Terraform provisions both environments.
- GitHub Actions deploys both environments.
- Route 53 health checks configured.
- DNS failover operational.
- Multi-AZ database enabled.
- Read replica configured.
- Standby reachable.
- Failover successfully demonstrated.

---

# Repository Structure

```
.github/workflows/

ansible/

infrastructure/
    terraform/
        modules/
            app_environment/
            alb/
            ec2/
            route53/
            rds/
            sqs/
            vpc/

docs/
    dr.md
```