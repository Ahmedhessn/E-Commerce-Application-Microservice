
Deploying a production-grade microservices e-commerce application on Amazon EKS requires:

* Infrastructure as Code (Terraform)
* CI/CD Pipelines (Jenkins)
* GitOps Deployment (ArgoCD)
* Container Registry (ECR)
* DNS & HTTPS (Route 53 + ACM)
* Observability & Security best practices

This guide walks through the complete setup — from cloning the repository to exposing the frontend securely over HTTPS.

---

# Step 1: Clone the GitHub Repository

Repository:
`https://github.com/Ahmedhessn/E-Commerce-Application-Microservice`

```bash
git clone https:https://github.com/Ahmedhessn/E-Commerce-Application-Microservice
cd Microservices-E-Commerce-eks-project
```

---

# Step 2: Configure AWS Credentials

```bash
aws configure
```

Provide:

* Access Key ID
* Secret Access Key
* Region (e.g., `us-east-1`)
* Output format: `json`

---

# Step 3: Create S3 Bucket for Terraform Remote State

```bash
cd s3-buckets/
terraform init
terraform plan
terraform apply -auto-approve
```

This enables:

* Remote state storage
* Team collaboration
* State locking

---

# Step 4: Provision Network & EC2 Infrastructure

```bash
cd ../terraform_main_ec2
terraform init
terraform plan
terraform apply -auto-approve
```

Expected output:

```
Apply complete! Resources: 24 added.
jumphost_public_ip = "18.x.x.x"
region = "us-east-1"
```

Verify:

```bash
terraform state list
```

---

# Step 5: Connect to EC2 (Jumphost)

From AWS Console → EC2 → Connect

Switch to root:

```bash
sudo -i
```

Verify installed tools:

```bash
git --version
java -version
jenkins --version
terraform -version
mvn -v
kubectl version --client
eksctl version
helm version
docker --version
trivy --version
```

---

# Step 6: Setup Jenkins

Access:

```
http://<EC2_PUBLIC_IP>:8080
```

1. Get admin password:

   ```bash
   cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
2. Install suggested plugins
3. Create first user
4. Finish setup

---

# Step 7: Install Required Jenkins Plugin

Install:

* ✅ Pipeline: Stage View

Restart Jenkins after installation.

---

# Step 8: Create Jenkins Pipeline – EKS Cluster

New Item → Pipeline
Name: `eks-terraform`

Pipeline config:

* Definition: Pipeline script from SCM
* Repo: GitHub repo above
* Branch: `*/master`
* Script Path: `eks-terraform/eks-jenkinsfile`

Build with parameter:

```
ACTION = apply
```

Verify EKS cluster:

```bash
aws eks --region us-east-1 update-kubeconfig --name project-eks
kubectl get nodes
```

---

# Step 9: Create Jenkins Pipeline – ECR

Name: `ecr-terraform`

Script Path:

```
ecr-terraform/ecr-jenkinfile
```

Build with:

```
ACTION = apply
```

Verify:

```bash
aws ecr describe-repositories --region us-east-1
```

Services created:

* emailservice
* checkoutservice
* recommendationservice
* frontend
* paymentservice
* productcatalogservice
* cartservice
* loadgenerator
* currencyservice
* shippingservice
* adservice

---

# Step 10: Build & Push Docker Images to Amazon Elastic Container Registry

## Add GitHub PAT to Jenkins

Manage Jenkins → Credentials → Global → Add

* Kind: Secret text
* ID: `my-git-pattoken`
* Description: git credentials

---

## Create Pipeline Jobs for Each Microservice

For each service:

New Item → Pipeline
Script Path:

```
jenkinsfiles/<service-name>
```

Example:

```
jenkinsfiles/emailservice
jenkinsfiles/frontend
jenkinsfiles/paymentservice
```

Click **Build**

This will:

* Build Docker image
* Scan with Trivy
* Push to ECR
* Update image tag in Kubernetes manifests

---

# Step 11: Install Argo CD

## Create Namespace

```bash
kubectl create namespace argocd
```

## Install ArgoCD

```bash
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify:

```bash
kubectl get pods -n argocd
```

---

## Expose ArgoCD

```bash
kubectl edit svc argocd-server -n argocd
```

Change:

```
type: ClusterIP
```

To:

```
type: LoadBalancer
```

Get DNS:

```bash
kubectl get svc argocd-server -n argocd
```

---

## Get Admin Password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
-o jsonpath="{.data.password}" | base64 -d && echo
```

Login:

* Username: `admin`
* Password: (above output)

---

# Step 12: Deploy Application with ArgoCD

Create namespace:

```bash
kubectl create namespace dev
```

In ArgoCD UI → New App:

* Name: `project`
* Repo: GitHub repo
* Path: `kubernetes-files`
* Cluster: default
* Namespace: `dev`
* Sync Policy: Automatic

Click **Create**

ArgoCD will:

* Pull manifests
* Deploy all microservices
* Auto-sync on changes

---

# Step 13: Configure Domain & HTTPS

We will use:

* Amazon Route 53
* AWS Certificate Manager
* Classic Load Balancer

---

## Step 13.1: Create Hosted Zone in Route 53

Create:

* Domain: `aluru.site`
* Type: Public Hosted Zone

Update nameservers at your domain registrar (e.g., Hostinger).

---

## Step 13.2: Request SSL Certificate in ACM

1. Open AWS Certificate Manager
2. Request Public Certificate
3. Add:

   * `aluru.site`
   * `www.aluru.site`
4. Choose DNS validation
5. Create DNS record in Route 53
6. Wait until status = **Issued**

---

## Step 13.3: Add HTTPS Listener to Classic Load Balancer

EC2 → Load Balancers → Listeners → Add:

* Protocol: HTTPS
* Port: 443
* Instance Protocol: HTTP
* Instance Port: 80 (or 8080)
* Certificate: Select ACM cert
* Security Policy: ELBSecurityPolicy-2021-06

---

## Step 13.4: Update Security Group

Allow:

* HTTPS (443)
* HTTP (80)

Source:

```
0.0.0.0/0
```

---

## Step 13.5: Configure DNS Record

Route 53 → Hosted Zone → Create Record:

* Type: A
* Alias: Yes
* Alias Target: Load Balancer DNS
* Region: us-east-1

---

# Final Test

Open:

```
https://aluru.site
```

Or test with:

```bash
curl -v https://aluru.site
```

Expected:

```
HTTP/1.1 200 OK
```

---

# Architecture Summary

CI/CD Flow:

GitHub → Jenkins → ECR → ArgoCD → EKS → Load Balancer → Route 53 → HTTPS

Infrastructure Flow:

Terraform → VPC → EC2 Jumphost → EKS → ECR → S3 Remote State





