#!/bin/bash

# =========================
# Apache Tomcat 9 Installer (Robust)
# =========================

TOMCAT_VERSION="9.0.109"
TOMCAT_ZIP="apache-tomcat-${TOMCAT_VERSION}.zip"

PRIMARY_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_ZIP}"
ARCHIVE_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_ZIP}"

INSTALL_DIR="/opt"

echo "🔹 Installing required packages"
yum install -y wget unzip tree lsof java-21-openjdk-devel

echo "🔹 Java Version:"
java -version

cd ${INSTALL_DIR}

echo "🔹 Trying primary Apache mirror..."
if wget ${PRIMARY_URL}; then
    echo "✅ Downloaded from primary mirror"
else
    echo "⚠️ Primary mirror failed, trying Apache archive..."
    if wget ${ARCHIVE_URL}; then
        echo "✅ Downloaded from archive"
    else
        echo "❌ Download failed from both sources"
        exit 1
    fi
fi

echo "🔹 Extracting Tomcat"
unzip -o ${TOMCAT_ZIP}

echo "🔹 Setting permissions"
chmod u+x ${INSTALL_DIR}/apache-tomcat-${TOMCAT_VERSION}/bin/*.sh

echo "🔹 Creating global commands"
ln -sf ${INSTALL_DIR}/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh /usr/bin/startTomcat
ln -sf ${INSTALL_DIR}/apache-tomcat-${TOMCAT_VERSION}/bin/shutdown.sh /usr/bin/stopTomcat

echo "🔹 Starting Tomcat"
startTomcat

sleep 5

echo "🔹 Checking Tomcat status"
lsof -i :8080 && echo "✅ Tomcat is running on port 8080"

echo "🎉 Tomcat ${TOMCAT_VERSION} installation completed"
echo "👉 Access: http://<EC2-PUBLIC-IP>:8080"
