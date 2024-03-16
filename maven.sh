#!/bin/bash

# Update package repositories
sudo apt update

# Install Apache Maven
sudo apt install maven -y

# Verify Maven installation
mvn -version
