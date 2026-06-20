# Final Project: Production-Ready High Availability Web Infrastructure

## 1. Executive Summary
This repository contains the complete production-grade Infrastructure as Code (IaC) deployment utilizing Terraform to provision a highly available, fault-tolerant, and secure web hosting environment on Amazon Web Services (AWS). 

The infrastructure implements an automated multi-layered application routing matrix capable of scaling across multiple Availability Zones (Multi-AZ) to eliminate single points of failure (SPOF) and guarantee business continuity.

---

## 2. Architectural Design & Traffic Pipeline
The system enforces strict decoupling of compute, network distribution, and firewalls layers:

* **Ingress Routing:** Public client traffic targets the Layer 7 Application Load Balancer (ALB) over standard HTTP port `80`.
* **Load Distribution:** The ALB acts as a reverse proxy, distributing processing requests evenly across underlying compute subnets using a round-robin algorithm.
* **Internal Back-End Routing:** Compute layers operate an automated internal server engine processing requests on an isolated application custom port `8080`.

```text
[Public Client] ---> (ALB Ingress: Port 80)
                           |
            +--------------+--------------+
            | (Multi-AZ Round-Robin)      |
            v                             v
[EC2 Target - Zone 1A]        [EC2 Target - Zone 1B]
(Application: Port 8080)      (Application: Port 8080)
