#!/bin/bash
# ===============================================
# SonarQube 9.6.1 Installation Script (Amazon Linux / RHEL / CentOS)
# ===============================================

echo "==== 1. Switching to root ===="
sudo su -

echo "==== 2. Fixing Time Sync ===="
timedatectl set-ntp true
timedatectl set-timezone UTC
systemctl restart chronyd || systemctl restart systemd-timesyncd
timedatectl

echo "==== 3. Installing Java 17 (Amazon Corretto) ===="
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel --nogpgcheck

echo "==== 4. Setting Java 17 as Default ===="
alternatives --set java /usr/lib/jvm/java-17-amazon-corretto/bin/java

echo "==== 5. Setting Required Kernel Parameters ===="
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

echo "==== 6. Installing Required Packages ===="
yum install wget unzip -y

echo "==== 7. Downloading SonarQube ===="
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip
unzip sonarqube-9.6.1.59531.zip
mv sonarqube-9.6.1.59531 sonarqube

echo "==== 8. Creating sonar User ===="
useradd sonar
echo 'sonar   ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

echo "==== 9. Setting Permissions for SonarQube Directory ===="
chown -R sonar:sonar /opt/sonarqube
chmod -R 775 /opt/sonarqube

echo "==== 10. Setting Java Environment for sonar User ===="
cat <<EOF >> /home/sonar/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

echo "==== 11. Switching to sonar user and starting SonarQube ===="
su - sonar -c "cd /opt/sonarqube/bin/linux-x86-64 && sh sonar.sh start"

echo "==== SonarQube Status ===="
su - sonar -c "cd /opt/sonarqube/bin/linux-x86-64 && sh sonar.sh status"

echo "========================================================"
echo " SonarQube Installation Completed Successfully!"
echo " Access SonarQube at:  http://<your-ec2-ip>:9000"
echo " Default Login: admin / admin"
echo " Logs:"
echo "   tail -f /opt/sonarqube/logs/sonar.log"
echo "   tail -f /opt/sonarqube/logs/es.log"
echo "========================================================"
