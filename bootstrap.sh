#!/usr/bin/env bash

echo "-- Instalare utilitare necesare si tool-uri folosite pt procesul de integrare continua --"

echo 'Install Open SSL '
echo "------------------------"
sudo apt-get update -y
sudo apt-get install openssl -y

echo 'Install DebConf '
echo "------------------------"
sudo apt-get update -y
sudo apt-get install debconf-utils -y

echo 'Install Java '
echo "------------------------"
sudo apt-get -y -q update
sudo apt-get install default-jre
sudo apt-get install default-jdk
sudo apt-get install python-software-properties

echo 'Install Java9 - Prerequisite for Jenkins'
echo "------------------------"
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "oracle-java9-installer shared/accepted-oracle-license-v1-1 select true"
debconf-set-selections <<< "oracle-java9-installer shared/accepted-oracle-license-v1-1 seen true"
sudo apt-get -q -y install oracle-java9-installer

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get -y -q update
sudo apt-get -q -y install oracle-java8-installer

echo 'Install GNOME '
echo "------------------------"
sudo apt-get -y -q update
sudo apt-get install gnome-shell -y
sudo apt-get install gnome-terminal -y
sudo apt-get install gnome-session-flashback -y
sudo apt-get install compizconfig-settings-manager -y
sudo apt-get install indicator-applet-appmenu -y
sudo add-apt-repository ppa:nilarimogard/webupd8
sudo apt-get -y update 
sudo apt-get install cardapio cardapio-gnomepanel -y

echo 'Install Chromium '
echo "------------------------"
sudo apt-get update -y
sudo apt-get install chromium-browser -y

echo 'Install Chrome'
echo "------------------------"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get update -y
sudo apt-get install google-chrome-stable -y

echo 'Install Nautilus FM '
echo "------------------------"
sudo add-apt-repository ppa:gnome3-team/gnome3
sudo apt-get update -y
sudo apt-get install nautilus -y

echo 'Install Sublime '
echo "------------------------"
sudo add-apt-repository ppa:webupd8team/sublime-text-2
sudo apt-get update -y
sudo apt-get install sublime-text -y

echo 'Install Atom '
echo "------------------------"
sudo add-apt-repository ppa:webupd8team/atom
sudo apt-get update -y
sudo apt-get install atom -y

echo 'Install Open Apache '
echo "------------------------"
sudo apt-get update -y
sudo apt-get install apache2 -y

echo 'Install PHP5 '
echo "------------------------"
sudo apt-get update -y
sudo apt-get install php5 -y

echo 'Install MySQL '
echo "------------------------"
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password root'
sudo apt-get -q -y install mysql-server-5.6

echo 'Install phPMyAdmin '
echo "------------------------"
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -q -y install phpMyAdmin

echo 'Install Git '
echo "------------------------"
sudo apt-get update
sudo apt-get install git -y



echo 'Install Maven in /usr/share/maven...'
echo "------------------------"
sudo apt-get update -y
sudo apt-get install maven -y

echo 'Install Jenkins '
echo "------------------------"
export DEBIAN_FRONTEND="noninteractive"
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo /etc/init.d/jenkins restart

echo 'Generate Sonar database...'
echo "------------------------"

if ["`mysql -u 'root' -p'root' -se'use sonar;' 2>&1`" == ""];
then
	echo "Go ahead with the existing database"	
	echo "DATABASE ALREADY EXISTS DELETE IF NECESSARY!"
	echo "Drop if necessary ---> Uncomment the line"
	mysql -u root -proot -e "DROP DATABASE IF EXISTS sonar;"
	mysql -u root -proot -e "DROP USER 'sonar'@'localhost';"
	mysql -u root -proot -e "DROP USER 'sonar'@'%';"
else
	echo "Go ahead and create a new database"	
fi

if ["`mysql -u 'root' -p'root' -se'use sonar;' 2>&1`" == ""];
then
	echo "DATABASE ALREADY EXISTS !"
else
	echo "Create Sonar Database"
	mysql -u root -proot -e "create database sonar character set UTF8;"
	mysql -u root -proot -e "CREATE USER 'sonar' IDENTIFIED BY 'sonar';"
	mysql -u root -proot -e "GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';"
	mysql -u root -proot -e "GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';"
	mysql -u root -proot -e "FLUSH PRIVILEGES;"
fi

 http://localhost:8081/sonar
echo 'Instalare SonarQube in fisierul /opt/sonar...'
echo "------------------------"
sudo wget 'https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.4.zip'
sudo unzip sonarqube-6.4.zip
sudo mv sonarqube-6.4 /opt/sonar

echo 'Configurare SonarQube'
echo "------------------------"
echo 'Setare parametrii de conexiune la baza de date creata anterior'
sudo sed -i 's|#sonar.jdbc.username=|sonar.jdbc.username=sonar|g' /opt/sonar/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.password=|sonar.jdbc.password=sonar|g' /opt/sonar/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar|sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar|g' /opt/sonar/conf/sonar.properties  

echo 'Setare port pe care va rula SonarQube'
sudo sed -i 's|#sonar.web.host=0.0.0.0|sonar.web.host=127.0.0.1|g' /opt/sonar/conf/sonar.properties
sudo sed -i 's|#sonar.web.context=|sonar.web.context=/sonar|g' /opt/sonar/conf/sonar.properties
sudo sed -i 's|#sonar.web.port=9000|sonar.web.port=8081|g' /opt/sonar/conf/sonar.properties

echo 'Setare parametrii de configurare'
sudo cp /opt/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
sudo sed -i 's|WRAPPER_CMD="./wrapper"|WRAPPER_CMD="/opt/sonar/bin/linux-x86-64/wrapper"|g' /etc/init.d/sonar
sudo sed -i 's|WRAPPER_CONF="../../conf/wrapper.conf"|WRAPPER_CONF="/opt/sonar/conf/wrapper.conf"|g' /etc/init.d/sonar
sudo sed -i 's|PIDDIR="."|PIDDIR="/var/run"|g' /etc/init.d/sonar

echo 'Inregistrare SonarQube ca si un serviciu Linux'
sudo update-rc.d -f sonar remove
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults

echo 'Start Serviciu Linux'
sudo service sonar start


 http://localhost:8082/nexus
echo 'Instalare Sonatype Nexus in fisierul /opt/sonar...'
echo "------------------------"
sudo mkdir /usr/local/nexus
wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz -P /tmp
sudo tar -xvzf /tmp/nexus-latest-bundle.tar.gz -C /usr/local/nexus/
sudo mv /usr/local/nexus/nexus-* /usr/local/nexus/nexus-last

sudo sed -i 's|NEXUS_HOME=".."|NEXUS_HOME="/usr/local/nexus/nexus-last"|g' /usr/local/nexus/nexus-last/bin/nexus
sudo sed -i 's|#RUN_AS_USER=|RUN_AS_USER=root|g' /usr/local/nexus/nexus-last/bin/nexus
sudo sed -i 's|wrapper.java.command=java|wrapper.java.command=/usr/lib/jvm/java-8-oracle/bin/java|g' /usr/local/nexus/nexus-last/bin/jsw/conf/wrapper.conf
cd /etc/init.d

sudo sed -i 's|application-port=8081|application-port=8082|g' /usr/local/nexus/nexus-last/conf/nexus.properties
sudo sed -i 's|application-host=0.0.0.0|application-host=127.0.0.1|g' /usr/local/nexus/nexus-last/conf/nexus.properties
sudo cp /usr/local/nexus/nexus-last/bin/nexus /etc/init.d/nexus

echo 'Inregistrare SonaType Nexus ca si un serviciu Linux'
sudo update-rc.d -f nexus remove
sudo chmod 755 /etc/init.d/nexus
sudo update-rc.d nexus defaults

echo 'Start Serviciu Linux'
sudo service nexus start

echo 'Stergere fisiere care nu mai sunt necesare'
rm /tmp/nexus-latest-bundle.tar.gz

sudo reboot
