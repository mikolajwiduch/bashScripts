#!/bin/bash

# Set variables
REGION="us-central1"
ZONE1="us-central1-a"
ZONE2="us-central1-b"
ZONE3="us-central1-c"
VPC_NAME="my-custom-vpc"
SUBNET_NAME="my-subnet"
INSTANCE_TEMPLATE="web-server-template"
INSTANCE_GROUP="web-server-group"
FIREWALL_ALLOW_SSH="allow-ssh"
FIREWALL_ALLOW_LB="allow-lb-traffic"
HEALTH_CHECK="http-basic-check"
BACKEND_SERVICE="web-backend"
URL_MAP="web-map"
HTTP_PROXY="web-http-proxy"
FORWARDING_RULE="web-http-rule"

echo " Setting up GCP environment..."

# Create VPC
gcloud compute networks create $VPC_NAME --subnet-mode=custom

# Create Subnet
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$VPC_NAME \
    --range=10.0.1.0/24 \
    --region=$REGION

# Create Firewall Rules
gcloud compute firewall-rules create $FIREWALL_ALLOW_SSH \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=allow-ssh

gcloud compute firewall-rules create $FIREWALL_ALLOW_LB \
    --network=$VPC_NAME \
    --allow=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=http-server

# Create Instance Template
gcloud compute instance-templates create $INSTANCE_TEMPLATE \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,allow-ssh \
    --network=$VPC_NAME \
    --subnet=$SUBNET_NAME \
    --region=$REGION \
    --metadata=startup-script='#! /bin/bash
        sudo apt update
        sudo apt install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2
        echo "<h1>Welcome to $(hostname) - Load Balanced</h1>" | sudo tee /var/www/html/index.html'

# Create Autoscaling Instance Group
gcloud compute instance-groups managed create $INSTANCE_GROUP \
    --base-instance-name=web-server \
    --size=1 \
    --template=$INSTANCE_TEMPLATE \
    --region=$REGION \
    --zones=$ZONE1,$ZONE2,$ZONE3

# Enable Autoscaling
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP \
    --region=$REGION \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60

# Create Health Check
gcloud compute health-checks create http $HEALTH_CHECK --port 80

# Create Backend Service
gcloud compute backend-services create $BACKEND_SERVICE \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=$HEALTH_CHECK \
    --global

# Add Instance Group to Backend Service
gcloud compute backend-services add-backend $BACKEND_SERVICE \
    --instance-group=$INSTANCE_GROUP \
    --instance-group-region=$REGION \
    --global

# Create URL Map
gcloud compute url-maps create $URL_MAP --default-service=$BACKEND_SERVICE

# Create HTTP Proxy
gcloud compute target-http-proxies create $HTTP_PROXY --url-map=$URL_MAP

# Create Global Forwarding Rule
gcloud compute forwarding-rules create $FORWARDING_RULE \
    --global \
    --target-http-proxy=$HTTP_PROXY \
    --ports=80

echo "Deployment completed successfully!"

# Get LB IP
gcloud compute forwarding-rules list --global
