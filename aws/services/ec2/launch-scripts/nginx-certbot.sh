#!/bin/bash
# Nginx and Certbot

apt update; apt -y upgrade

# Set hostname
echo 'example.com' > /etc/hostname

# Configure Nginx
apt install -y nginx
mkdir /var/www/example
echo 'Hello world' > /var/www/example/index.html

cat > /etc/nginx/sites-available/example << EOF
server {
  listen 80;
  listen [::]:80;
  root   /var/www/example;
  index  index.html index.htm;
  server_name  example.com www.example.com;

  access_log /var/log/nginx/example-access.log;
  error_log /var/log/nginx/example-error.log;

  client_max_body_size 10M;

  location / {
    index index.html;
  }
}
EOF

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/example
systemctl restart nginx

# Setup Certbot
apt install -y python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com --register-unsafely-without-email --agree-tos

reboot now
