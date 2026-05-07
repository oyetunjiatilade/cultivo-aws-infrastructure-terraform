# ADR 002: EKS Over ECS for Container Orchestration

**Status:** Accepted  
**Date:** 2024-01-16  
**Deciders:** Platform Engineering, Architecture Review Board

## Context

We needed to select a container orchestration platform for microservices workloads. Requirements included:
- Support for both stateless and stateful applications
- Multi-region deployment capability
- Ecosystem tooling (service mesh, ingress, monitoring)
- Long-term career growth for platform engineers
- Vendor flexibility

We evaluated ECS Fargate/EC2 vs. EKS (Kubernetes).

## Decision

We chose **EKS (Elastic Kubernetes Service)** as the primary orchestration platform.

## Rationale

1. **Kubernetes Ecosystem**: The Kubernetes ecosystem (Helm, Istio, Prometheus, ArgoCD) is mature and portable. Skills are transferable across clouds.

2. **Multi-Region Deployment**: Kubernetes clusters are lightweight to replicate across regions. ECS requires separate task definitions and service configs per region.

3. **Stateful Workloads**: EBS CSI driver and persistent volumes enable databases, caches, and other stateful apps. ECS is primarily stateless.

4. **Developer Experience**: Helm charts provide templating and reusability. ECS requires infrastructure-as-code Terraform/CloudFormation for the same capability.

5. **Cost Flexibility**: EKS supports on-demand, spot, and reserved instances in a single cluster. ECS Fargate pricing is less flexible.

6. **Industry Adoption**: Kubernetes skills are in higher demand. Hiring and retention easier with Kubernetes expertise.

## Consequences

**Positive:**
- Portable skills across cloud providers
- Rich ecosystem of open-source tools
- Better multi-region story
- Stateful workload support
- Strong community and documentation

**Negative:**
- Kubernetes adds operational complexity (control plane patching, node management)
- Learning curve steeper than ECS for new platform engineers
- More resources required for HA setup (control plane + data plane)
- Requires additional observability/cost analysis tooling

## Mitigation

- Use AWS-managed EKS to reduce control plane burden
- Implement GitOps (ArgoCD) for declarative deployments
- Use Karpenter or cluster-autoscaler for cost optimization
- Invest in team training (CKA certification encouraged)
- Run periodic FinOps reviews to track cluster spend

## References

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Cost Optimization](https://kubernetes.io/docs/concepts/configuration/overview/)
