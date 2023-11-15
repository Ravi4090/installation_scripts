#!/bin/bash

# Update the package lists
sudo yum update -y

# Install Java
sudo dnf install java-17-amazon-corretto -y 

# Install Jenkins

# Step 1 : Adding Jenkins Repo  
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo   
 
#Step 2 : Importing key file from Jenkins-CI to enable installation from the package
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#Step 3 :Upgrading all the packages
sudo yum upgrade

# Step 4 : Installing Jenkins
sudo yum install jenkins -y

#Step 5 : Enable the Jenkins service to start at boot
sudo systemctl enable jenkins

#Step 6 :Start Jenkins service
sudo systemctl start jenkins

echo "*********************** Jenkins Started ***********************"

#Step 7 :Checking Jenkins Service Status
sudo systemctl status jenkins

#Printing Jenkins Admin Password If you are installing on an Ec2 server
echo "Admin Password : "
sudo cat /var/lib/jenkins/secrets/initialAdminPassword