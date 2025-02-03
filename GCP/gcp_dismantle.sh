#!/bin/bash

# Set variables
REGION="us-central1"
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

echo "Starting GCP dismantle process..."

# Delete Load Balancer Components
echo "Deleting Load Balancer..."
gcloud compute forwarding-rules delete $FORWARDING_RULE --global -q
gcloud compute target-http-proxies delete $HTTP_PROXY -q
gcloud compute url-maps delete $URL_MAP -q
gcloud compute backend-services delete $BACKEND_SERVICE --global -q
gcloud compute health-checks delete $HEALTH_CHECK -q

# Delete Autoscaling Instance Group
echo "Deleting Autoscaling Instance Group..."
gcloud compute instance-groups managed delete $INSTANCE_GROUP --region=$REGION -q

# Delete Instance Template
echo "Deleting Instance Template..."
gcloud compute instance-templates delete $INSTANCE_TEMPLATE -q

# Delete Firewall Rules
echo "Deleting Firewall Rules..."
gcloud compute firewall-rules delete $FIREWALL_ALLOW_SSH $FIREWALL_ALLOW_LB -q

# Delete VPC & Subnet
echo "Deleting VPC and Subnet..."
gcloud compute networks subnets delete $SUBNET_NAME --region=$REGION -q
gcloud compute networks delete $VPC_NAME -q

echo "GCP dismantle complete!"
