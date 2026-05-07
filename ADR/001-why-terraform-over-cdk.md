# ADR 001: Terraform Over AWS CDK

**Status:** Accepted  
**Date:** 2024-01-15  
**Deciders:** Platform Engineering, Security

## Context

We needed to choose an Infrastructure as Code tool that would be used across multiple AWS accounts by distributed teams. Key requirements were:
- Multi-team collaboration (ops + platform + security reviews)
- Easy audit trail and change tracking
- Vendor lock-in minimization
- State management and cost visibility
- Ability to manage non-AWS resources (DNS, monitoring)

We evaluated:
- **Terraform**: Declarative, HCL, wide ecosystem, mature tooling
- **CloudFormation**: AWS-native, but verbose YAML/JSON
- **AWS CDK**: Programming language-based, great for complex logic

## Decision

We chose **Terraform** as the primary IaC tool for AWS infrastructure.

## Rationale

1. **Auditability**: HCL is concise and readable in pull request reviews. Security reviewers can understand infrastructure changes without domain-specific programming knowledge.

2. **Multi-cloud Ready**: By standardizing Terraform, we create a migration path to multi-cloud (Azure, GCP) without tool changes. CDK locks us into AWS ecosystem.

3. **State Management**: Terraform's explicit state model (S3 + DynamoDB locking) provides fine-grained control over infrastructure lifecycle. CDK abstracts this away.

4. **Team Velocity**: HCL has lower cognitive load for ops teams. CDK requires programming expertise; not all ops folks are comfortable with Python/TypeScript.

5. **Cost Estimation**: Terraform estimates can be integrated into CI/CD before apply. CDK requires post-deployment cost analysis.

6. **Modularity**: Terraform modules are straightforward to version and reuse. CDK constructs can become tightly coupled.

## Consequences

**Positive:**
- Easier cross-team collaboration and code review
- Clear audit trail in Git for all infrastructure changes
- Vendor agnostic foundation for future migrations
- Strong community support and third-party modules

**Negative:**
- HCL has less expressiveness than programming languages for complex conditional logic
- State file management requires discipline (versioning, encryption, locking)
- Larger terraform modules can become harder to test than CDK constructs

## Mitigation

- Enforce state locking and encryption at all times
- Use `terraform fmt` and linting (TFLint) in CI/CD
- Maintain comprehensive module documentation
- For highly complex logic, use Terraform's local-exec provisioner to invoke helper scripts

## References

- [Terraform vs CDK Comparison](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Hashicorp Terraform Best Practices](https://www.terraform.io/cloud-docs/state)
