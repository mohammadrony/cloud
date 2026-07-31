# EC2 and CodePipeline to Deploy Node and MySQL app

## Create public EC2 instance and copy db.sql instance

```bash
scp -i <ssh-pem-file> <db-sql-file> ec2-user@<ec2-public-ip>:~/
ssh -i <ssh-pem-file> ec2-user@<ec2-public-ip>
```

## Create RDS MySQL instance in private subnet in same VPC

## Install MySQL in Amazon Linux 2023

```bash
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo dnf install mysql80-community-release-el9-1.noarch.rpm
sudo dnf install mysql-community-server
```

## Connect to RDS instance and Load db.sql script

```bash
mysql -h <db-host> -P 3306 -u <db-user|admin> -p < db.sql
```

## Create private EC2 launch template with user data

```bash
#!/bin/bash
yum -y update
yum -y install ruby wget
BUCKET="aws-codedeploy-ap-southeast-1"
REGION="ap-southeast-1"
wget https://${BUCKET}.s3.${REGIOIN}.amazonaws.com/latest/install
chmod +x ./install
./install auto

service codedeploy-agent status
```

## Configure Auto Scaling Group with ALB and Target group

- Configure auto scaling group in **private subnet**.
- Configure application load balancer in **public subnet**.
- Configure target group with instance **launch template**.
- Configure CPU tracking policy while creating scaling group.

## Configure appspec.yml file in root directory of the repository

```bash
version: 0.0
os: linux
files:
  - source: /
    destination: /var/www/html/
permissions:
  - object: /home/ec2-user
    owner: ec2-user
    group: ec2-user
    type:
      - directory
      - file
hooks:
  BeforeInstall:
    - location: deploy_scripts/install.sh
      timeout: 300
      runas: root
  ValidateService:
    - location: deploy_scripts/validate.sh
      timeout: 60
      runas: ec2-user
```

## deploy_scripts/install.sh file

```bash
# Install LAMP in Amazon Linux 2023
# dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
```

## Install Apache in Amazon Linux 2

```bash
yum install -y httpd httpd-tools mod_ssl
```

## Install PHP

```bash
yum install -y amazon-linux-extras
amazon-linux-extras enable php7.4
yum clean metadata
yum -y install php php-common php-pear
yum -y install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip}
```

## Install validator package

```bash
yum -y install nc
```

## Start HTTPD service

```bash
systemctl start httpd
systemctl enable httpd
```

## deploy_scripts/validate.sh

```bash
#!/usr/bin/env bash
sleep 10
nc -zv 127.0.0.1 80
```

## Configure role for CodeDeploy in Blue/Green deployment

Add `AWSCodeDeployRole` and an extra policy for B/G deployment

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "ec2:CreateTags",
                "ec2:RunInstances"
            ],
            "Resource": "*"
        }
    ]
}
```

in `CodeDeployRole`.
