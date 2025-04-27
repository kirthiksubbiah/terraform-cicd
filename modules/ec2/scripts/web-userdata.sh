#!/bin/bash

# Run commands as ec2-user
su - ec2-user <<'EOF'
set -e

# Fetch app files from S3
cd ~/
aws s3 cp s3://${project_prefix}-code-bucket/web-tier/ web-tier --recursive

# Install app dependencies
cd ~/web-tier
npm install

# Build the application
npm run build

# Update nginx config
sudo aws s3 cp s3://${project_prefix}-code-bucket/nginx.conf /etc/nginx/nginx.conf

# Restart nginx
sudo service nginx restart

# Give permissions
chmod -R 755 /home/ec2-user

# Start nginx on boot
sudo chkconfig nginx on

EOF