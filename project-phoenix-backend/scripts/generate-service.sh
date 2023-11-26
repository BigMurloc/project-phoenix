#!/bin/bash

#Enter project name
echo -n "Project name: "
read service_name

# generate spring boot project using nx spring boot plugin
nx g @nxrocks/nx-spring-boot:project "$service_name"-service \
--projectType application \
--buildSystem maven-project \
--packaging jar \
--language java \
--javaVersion 21 \
--groupId com.bigmurloc \
--artifactId "$service_name"-service \
--packageName com.bigmurloc."$service_name"-service \
--dependencies actuator,web,cloud-config-client,cloud-eureka \
--addToExistingParentModule true \
--parentModuleName project-phoenix-backend

# adjust generated service
config_file="./templates/serviceName-dev.yaml"
application_file="./templates/application.yaml"
config_destination_dir="../config-service/src/main/resources/config"
application_destination_dir="../$service_name-service/src/main/resources"
last_known_service_port_file="./templates/last-known-service-port"

# read and increment last known service port
service_port=$(<$last_known_service_port_file)
((service_port++))
echo "$service_port" > $last_known_service_port_file

# copy created service config to config-service
sed -e "s|\${SERVICE_PORT}|$service_port|g" "$config_file" > "$config_destination_dir/$service_name-service-dev.yaml"

#remove application.properties
rm "../$service_name-service/src/main/resources/application.properties"

#add application.yaml
sed -e "s|\${SERVICE_NAME}|$service_name-service|g" "$application_file" > "$application_destination_dir/application.yaml"


echo "Service $service_name successfully created with port $service_port"