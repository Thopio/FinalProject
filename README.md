
FINAL PROJECT REPORT & DOCUMENTATION

Student: Jesus Oscar Lupio Thomas
University: Dankook University 
Course: Cloud Computing
Date: June 2026


1. PROJECT OVERVIEW & EXECUTIVE SUMMARY

For my final project, I took a standard monolithic web setup (where the 
website and the application files live on a single isolated server) 
and split it up into a highly available, distributed cloud architecture 
using Terraform. 

Instead of running a single server that could easily crash under high 
traffic, this setup deploys two separate Amazon EC2 web instances 
distributed across different Availability Zones (us-east-1a and us-east-1b) 
and balances the incoming traffic using an AWS Application Load Balancer 
(ALB). This eliminates any Single Point of Failure 
(SPOF), making the entire infrastructure stable, fault-tolerant, and secure.


2. WHAT I DID & PROBLEMS I FIXED (STEP-BY-STEP)


Step 1: Fixing the AWS Academy Token (403 Error)

While working on the terminal, my AWS Academy temporary credentials 
expired in the middle of compilation, and Terraform threw a 403 Forbidden 
or InvalidClientTokenId error. 
* To fix this, I cleared out the old expired tokens using the "unset" 
  command.
* Then, I grabbed the fresh credentials from the AWS Academy dashboard, 
  pasted them into my terminal, and ran "aws sts get-caller-identity" 
  to make sure the connection was active again.

Step 2: Running Terraform Apply

With the new credentials live, I ran "terraform apply -auto-approve". 
It compiled perfectly with 0 errors and successfully synced up with 
my live infrastructure state, activating the Application Load Balancer.

Step 3: Cleaning up Git for the Push 

When I tried to push my files to the GitHub classroom repository, 
GitHub blocked my upload. The error said that a file inside the hidden 
".terraform/" folder was over 670 MB, which completely exceeds GitHub's 
100 MB file limit.
* The fix: That massive file was just the local AWS provider binary 
  that Terraform downloads automatically. It shouldn't be on GitHub anyway. 
* I used "git rm -r --cached .terraform/" to remove it from Git's memory 
  without deleting it from my computer.
* After that, my repository became super light (less than 1 MB), and 
  the push went through instantly!


3. SYSTEM ARCHITECTURE & TRAFFIC FLOW

The project separates network ingress distribution from the backend 
compute instances to ensure high availability:

* Ingress Distribution (ALB): A public-facing Application Load Balancer 
  that receives client requests on public HTTP port 80.
* Compute Tier (EC2): Two separate EC2 instances running in different 
  subnets hosting the core application services.
* Internal Routing Matrix: The ALB acts as a proxy, forwarding user 
  requests to the backend EC2 targets over a custom application port (8080).

DIAGRAM:
[Public Client Traffic] ---> (ALB Ingress: Port 80)
                                    |
                   ┌────────────────┴────────────────┐
                   v (Round-Robin Balance)           v
        [EC2 Target - Zone 1A]            [EC2 Target - Zone 1B]
        (Application: Port 8080)          (Application: Port 8080)


4. NETWORK SECURITY & PERIMETER ISOLATION

Security is enforced using strict security-group-to-security-group 
rules instead of open IP ranges to protect the backend instances:

* ALB Security Group: Open to the public internet (0.0.0.0/0) on port 80 
  to allow user web browser handshakes.
* EC2 Security Group: Completely closed to the direct public internet. 
  It explicitly restricts inbound traffic on port 8080 to only accept 
  packets that originate directly from the ALB Security Group signature.


5. AUTOMATION & BOOTSTRAP SEQUENCE

Server provisioning is fully automated using a "user-data.sh" script 
triggered dynamically during the instance launch lifecycle:

1. It updates system package mirrors and installs the Nginx web server 
   engine.
2. It configures the Nginx server block files to run and listen explicitly 
   on the custom application port 8080.
3. It generates dynamic environment logs so the load balancer can perform 
   automated target health checks.


6. REPOSITORY FILE GUIDE

* main.tf      - Core infrastructure setup (ALB resource mappings, target 
                 group registries, multi-AZ subnets, and EC2 resources).
* variables.tf - Input configuration schemas (region definitions, naming 
                 variables, and application ports).
* outputs.tf   - Live architecture outputs (Active ALB canonical DNS URL, 
                 target group ARNs, and instance identifiers).
* user-data.sh - The automation script responsible for bootstrapping the 
                 server layer.


