#!/usr/bin/env bash
set -euo pipefail

REGION=${1:-eu-west-1}
SUBNET=${2:-subnet-022e85f69a01a4d68}
AMI=${3:-ami-0ef0fafba270833fc}   # Ubuntu 22.04 official

echo "Launching test instance in $REGION ..."
INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI" \
  --instance-type t3.small \
  --subnet-id "$SUBNET" \
  --iam-instance-profile Name=PackerBuilderRole \
  --no-associate-public-ip-address \
  --user-data '#!/bin/bash
mkdir -p /tmp/ssm
cd /tmp/ssm
curl -sSL https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -o amazon-ssm-agent.deb
dpkg -i amazon-ssm-agent.deb
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=packer-ssm-test}]' \
  --query 'Instances[0].InstanceId' --output text)

echo "Instance launched: $INSTANCE_ID"
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

echo "Waiting for SSM agent to register (up to 90 seconds)..."
sleep 60  # Give SSM time to register

echo "Checking SSM status..."
aws ssm describe-instance-information \
  --region "$REGION" \
  --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
  --query "InstanceInformationList[0].PingStatus" --output text || echo "Not registered yet"

echo ""
echo "=================================================="
echo "Instance ready for SSM Session Manager"
echo "=================================================="
echo "Run this command to connect:"
echo "    aws ssm start-session --region $REGION --target $INSTANCE_ID"
echo "=================================================="