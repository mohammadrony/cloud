#!/bin/bash
# CodeDeploy Agent

yum -y update
yum -y install ruby wget
bucket_name="aws-codedeploy-ap-southeast-1"
region="ap-southeast-1"
wget https://${bucket_name}.s3.${region}.amazonaws.com/latest/install
chmod +x ./install
./install auto

service codedeploy-agent status
