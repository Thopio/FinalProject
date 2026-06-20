# Toy Example 03: ALB with Two EC2 Targets

This folder is a student template, not a fully completed solution.
The EC2 baseline is mostly preserved, but several ALB-related sections are intentionally removed for students to complete.

This example creates two EC2 instances in different subnets, then places an Application Load Balancer in front of them.
It extends Example 02 by adding a target group, target attachments, and an HTTP listener.

## Learning Focus

- How to separate ALB and EC2 security groups
- How to run the web service on a custom application port
- How to create a target group and register EC2 instances
- How to create an ALB and forward traffic with a listener
- How to inspect load balancer resources with Terraform outputs and state commands

## Included Files

- `versions.tf`: Terraform and provider requirements
- `variables.tf`: input variables
- `main.tf`: subnet selection, EC2 instances, ALB, target group, listener
- `outputs.tf`: ALB DNS, target group ARN, instance IDs, and subnet IDs
- `user-data.sh`: installs and starts Nginx on port `8080`
- `terraform.tfvars.example`: example variable values
- `commands.md`: command examples with English comments

## Lab Outcome

The lab creates:

- one public ALB
- two EC2 instances in two different subnets
- one target group
- one listener on port `80`
- one Nginx page on each EC2 instance, served on port `8080`

Traffic path:

- client -> ALB port `80`
- ALB -> EC2 port `8080`

## Quick Start

```bash
export project_root="/path/to/your/project_root"
cd "$project_root/eng/toy-examples/terraform/terraform_example/terraform-03-alb-two-ec2"

# Load AWS Academy temporary credentials into environment variables.
export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_SESSION_TOKEN="<your-session-token>"

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt

# Complete the TODO(student) sections before validation.
terraform validate
terraform plan -out plan.out
terraform apply plan.out
terraform output
ALB_DNS=$(terraform output -raw alb_dns_name)
curl "http://${ALB_DNS}"
terraform destroy
```

## Notes

- The EC2 instances only accept application traffic from the ALB security group.
- The ALB spans the two selected subnets, so the example also demonstrates a basic multi-subnet front end.
- Keep sensitive values such as `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN` in environment variables only.
- Use `terraform.tfvars` only for non-sensitive inputs such as `aws_region`, `name_prefix`, `instance_type`, and `app_port`.

## Student Tasks

- Complete the ALB naming locals.
- Complete the ALB security group and the EC2 security-group-to-security-group rule.
- Complete the target group, target attachments, ALB resource, and listener forwarding rule.
