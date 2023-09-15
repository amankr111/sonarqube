#!/bin/bash
sudo apt-get update -y

# Install PostgreSQL
sudo apt update -y
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create SonarQube Database
sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "ALTER USER sonar WITH SUPERUSER;"


sudo apt-get install openjdk-11-jdk -y
sudo apt-get install zip -y

sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.8.0.63668.zip
sudo unzip sonarqube-9.8.0.63668.zip
sudo mv sonarqube-9.8.0.63668 /opt/sonarqube
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R

cd /opt/sonarqube/extensions/plugins
sudo wget https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.14.0/sonarqube-community-branch-plugin-1.14.0.jar

sudo echo "sonar.jdbc.username=sonar" >> /opt/sonarqube/conf/sonar.properties
sudo echo "sonar.jdbc.password=sonar" >> /opt/sonarqube/conf/sonar.properties
#sudo echo "sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube" >> /opt/sonarqube/conf/sonar.properties

sudo echo "sonar.web.javaAdditionalOpts=-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=web" >> /opt/sonarqube/conf/sonar.properties
sudo echo "sonar.ce.javaAdditionalOpts=-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=ce" >> /opt/sonarqube/conf/sonar.properties


sudo echo "[Unit]"                                             >> /etc/systemd/system/sonar.service
sudo echo "Description=SonarQube service"                      >> /etc/systemd/system/sonar.service
sudo echo "After=syslog.target network.target"                 >> /etc/systemd/system/sonar.service

sudo echo "[Service]"                                          >> /etc/systemd/system/sonar.service
sudo echo "Type=forking"                                       >> /etc/systemd/system/sonar.service

sudo echo "ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start" >> /etc/systemd/system/sonar.service
sudo echo "ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop"   >> /etc/systemd/system/sonar.service

sudo echo "User=sonar"   >> /etc/systemd/system/sonar.service
sudo echo "Group=sonar"  >> /etc/systemd/system/sonar.service
sudo echo "Restart=always"  >> /etc/systemd/system/sonar.service

sudo echo "LimitNOFILE=65536"   >> /etc/systemd/system/sonar.service
sudo echo "LimitNPROC=4096"     >> /etc/systemd/system/sonar.service

sudo echo "[Install]"  >> /etc/systemd/system/sonar.service
sudo echo "WantedBy=multi-user.target"  >> /etc/systemd/system/sonar.service


sudo systemctl enable sonar
sudo systemctl start sonar


sudo echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo echo "fs.file-max=65536"  >> /etc/sysctl.conf 
sudo echo "ulimit -n 65536"  >> /etc/sysctl.conf
sudo echo "ulimit -u 4096" >> /etc/sysctl.conf

sudo reboot
