#!/bin/bash
set -e

echo "========== Nexus Installation Started =========="

# Step 1: Check RAM
echo "Checking system memory..."
free -h

# Step 2: Switch to root check
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Step 3: Install required packages
echo "Installing required packages..."
yum install -y tar wget tree curl

# Step 4: Check Java
if ! command -v javac &> /dev/null; then
  echo "Java not found. Installing Amazon Corretto Java 8..."

  rpm --import https://yum.corretto.aws/corretto.key
  curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
  yum install -y java-1.8.0-amazon-corretto-devel --nogpgcheck
else
  echo "Java already installed"
fi

java -version

# Step 5: Create nexus user
if ! id nexus &>/dev/null; then
  echo "Creating nexus user..."
  useradd nexus
fi

# Step 6: Download Nexus
cd /opt
if [ ! -f nexus-3.70.1-02-java8-unix.tar.gz ]; then
  echo "Downloading Nexus..."
  wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java8-unix.tar.gz
fi

# Step 7: Extract Nexus
if [ ! -d /opt/nexus ]; then
  echo "Extracting Nexus..."
  tar -xzf nexus-3.70.1-02-java8-unix.tar.gz
  mv nexus-3.70.1-02 nexus
fi

# Step 8: Create sonatype-work
mkdir -p /opt/sonatype-work

# Step 9: Permissions
echo "Setting permissions..."
chown -R nexus:nexus /opt/nexus /opt/sonatype-work
chmod -R 775 /opt/nexus /opt/sonatype-work

# Step 10: Configure nexus.rc
echo "Configuring nexus.rc..."
sed -i 's/^#run_as_user=/run_as_user="nexus"/' /opt/nexus/bin/nexus.rc

# Step 11: Create systemd service
echo "Creating systemd service..."
cat <<EOF >/etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Step 12: Enable & start service
echo "Starting Nexus service..."
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

# Step 13: Status
systemctl status nexus --no-pager

echo "========== Nexus Installation Completed =========="
echo "Access Nexus at: http://<EC2-IP>:8081"
echo "Admin password:"
cat /opt/sonatype-work/nexus3/admin.password
