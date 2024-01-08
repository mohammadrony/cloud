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

# Import library database
tee -a /librarydb.sql << EOF
CREATE USER IF NOT EXISTS 'libraryapp'@'%' IDENTIFIED WITH mysql_native_password BY '12345678abc';
-- GRANT ALL PRIVILEGES ON librarydb.* TO 'libraryapp'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON librarydb.* TO 'libraryapp'@'%';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS librarydb;
EOF
mysql -h <host> -P 3306 -u <username> -p<password> -e 'source /librarydb.sql'

# Create build and run application script
tee -a /home/ec2-user/get-and-run-app.sh << EOF
# Build application
git clone https://<username>:<password>@gitlab.com/<project-group>/<repository>.git -b <branch> ~/app
cd ~/app
mvn clean package

# Run application
cp ~/app/target/*.jar ~/
pkill -9 java || true
nohup java -jar ~/*.jar > ~/log.txt 2>&1 &
EOF

# Execute script
chown ec2-user:ec2-user /home/ec2-user/get-and-run-app.sh
su -c "source ~/.bashrc; source ~/get-and-run-app.sh" ec2-user
