#!/bin/bash
# Run commands as ec2-user
su - ec2-user <<'EOF'

# Fetch app files from S3
cd ~/
aws s3 cp s3://${project_prefix}-code-bucket/app-tier/ app-tier --recursive

# Install app dependencies
cd ~/app-tier
npm install

# Start the app with PM2
pm2 start index.js

# Save PM2 process list
pm2 save

EOF
