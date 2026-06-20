# Commands Log Template

## Preflight

```bash
# Confirm that AWS Academy temporary credentials are present as environment variables.
test -n "$AWS_ACCESS_KEY_ID" && echo "AWS_ACCESS_KEY_ID is set"
test -n "$AWS_SECRET_ACCESS_KEY" && echo "AWS_SECRET_ACCESS_KEY is set"
test -n "$AWS_SESSION_TOKEN" && echo "AWS_SESSION_TOKEN is set"

# Confirm that AWS credentials are active in the current shell.
aws sts get-caller-identity

# Confirm the default AWS region that Terraform will use.
aws configure get region
```

Key output:

Interpretation:

## Init, Plan, and Apply

```bash
# Initialize the working directory and install the AWS provider.
terraform init

# Normalize formatting before validation and planning.
terraform fmt

# Check syntax and provider/resource references.
terraform validate

# Save the reviewed execution plan to a file.
terraform plan -out plan.out

# Apply exactly the plan that was reviewed.
terraform apply plan.out
```

Key output:

Interpretation:

## Outputs and Service Test

```bash
# Print all outputs so the ALB DNS name and instance IDs are visible.
terraform output

# Print only the ALB DNS value without quotes for easy shell reuse.
terraform output -raw alb_dns_name

# Send repeated requests through the load balancer to observe both targets.
ALB_DNS=$(terraform output -raw alb_dns_name)
for i in $(seq 1 10); do curl -s "http://${ALB_DNS}"; echo; done
```

Key output:

Interpretation:

## State Inspection

```bash
# Show one tracked ALB resource in detail from the Terraform state.
terraform state show aws_lb.web

# Show the target group configuration stored in the Terraform state.
terraform state show aws_lb_target_group.web
```

Key output:

Interpretation:

## AWS Verification

```bash
# Check the load balancer from the AWS API using the name returned by Terraform.
aws elbv2 describe-load-balancers --names "$(terraform output -raw alb_name)"

# Check target health from the AWS API using the target group ARN returned by Terraform.
aws elbv2 describe-target-health --target-group-arn "$(terraform output -raw target_group_arn)"
```

Key output:

Interpretation:

## Cleanup

```bash
# Delete the ALB, EC2 instances, and supporting resources.
terraform destroy
```

Key output:

Interpretation:

## Credential Handling Note

```text
Store AWS Academy temporary credentials in environment variables only.
Do not put AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, or AWS_SESSION_TOKEN into terraform.tfvars.
```
