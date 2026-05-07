# ADR 003: Multi-Account AWS Strategy

**Status:** Accepted  
**Date:** 2024-01-17  
**Deciders:** Security, Finance, Platform Engineering

## Context

We operate workloads across dev, staging, and production. We decided between:
- Single AWS account with IAM-based isolation
- Multiple AWS accounts with cross-account roles

Requirements: Blast radius containment, separate billing per environment, audit trails, cost allocation.

## Decision

**Multi-account architecture** with separate AWS accounts per environment (dev, prod) and isolated workload accounts.

## Account Structure

Organization Root includes: Management Account, Dev Account, Prod Account, Shared Services Account

## Rationale

1. **Blast Radius**: Compromised dev cannot affect production. IAM mistakes won't cascade.
2. **Separate Billing**: Finance tracks spend per environment and chargeback teams.
3. **Regulatory Compliance**: Audit logs and backups in separate account.
4. **Root Protection**: Root credentials stored offline. Multi-account requires less root-level access.
5. **Service Control Policies**: Environment-specific SCPs prevent unencrypted RDS in prod.
6. **Team Isolation**: Teams access only assigned accounts via federated identity.

## Consequences

**Positive:**
- Strong isolation and security posture
- Clear cost attribution and chargeback
- Regulatory compliance easier to demonstrate
- Safer experimentation in dev
- Supports multi-region disaster recovery

**Negative:**
- More AWS accounts to manage and monitor
- Cross-account role assumptions add latency
- Shared services costs scale linearly
- Slightly more complex CI/CD pipelines

## Implementation

- AWS Organizations with Service Control Policies
- Cross-account roles via Terraform assume_role provider
- Centralized logging to Shared Services account
- Cost anomaly detection per account
- AWS Config rules for compliance across accounts

## References

- AWS Well-Architected Framework - Security Pillar
- AWS Organizations Best Practices
