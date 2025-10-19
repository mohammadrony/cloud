#!/bin/bash
# Apache Java and MySQL

# Install packages
dnf update -y
dnf install -y java-11-amazon-corretto java-11-amazon-corretto-devel maven
dnf install -y mariadb105 git httpd

# Prepare httpd server for 8080
tee -a /etc/httpd/sites-available/app << EOF
<VirtualHost *:80>
  ServerAdmin root@example.com
  ServerName app.example.com
  DefaultType text/html
  ProxyRequests off
  ProxyPreserveHost On
  ProxyPass / http://localhost:8080/
  ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOF
rm /etc/httpd/sites-enabled/default
ln -s /etc/httpd/sites-available/app /etc/httpd/sites-enabled/app

systemctl restart httpd

# Export JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> ~ec2-user/.bashrc
echo 'PATH=$JAVA_HOME/bin:$PATH' >> ~ec2-user/.bashrc

# Import database
# Replace DB_NAME and APP_USER with real value.
tee -a /mydatabase.sql << EOF
CREATE USER IF NOT EXISTS 'APP_USER'@'%' IDENTIFIED WITH mysql_native_password BY '12345678abc';
-- GRANT ALL PRIVILEGES ON DB_NAME.* TO 'APP_USER'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON DB_NAME.* TO 'APP_USER'@'%';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS DB_NAME;
EOF
mysql -h <host> -P 3306 -u <username> -p<password> -e 'source /mydatabase.sql'

# Create build and run application script
# Replace USERNAME, PASSWORD, ORGANIZATION, REPOSITORY, BRANCH and APP with real value.
tee -a /home/ec2-user/get-and-run-app.sh << EOF
# Build application
git clone https://USERNAME:PASSWORD@github.com/ORGANIZATION/REPOSITORY.git -b BRANCH ~/APP
cd ~/APP
mvn clean package

# Run application
cp ~/APP/target/*.jar ~/
pkill -9 java || true
nohup java -jar ~/*.jar > ~/log.txt 2>&1 &
EOF

# Execute script
chown ec2-user:ec2-user /home/ec2-user/get-and-run-app.sh
su -c "source ~/.bashrc; source ~/get-and-run-app.sh" ec2-user
