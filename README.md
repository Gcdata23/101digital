# 101digital


## Deliverables:
### Item 1 Infrastructure architecture diagram which shows all the infrastructure components required to deploy this application with logical connections between components

![Image](101digital.drawio.png)

### Item 2 Terraform scripts to create all the infrastructure components (The Terraform code must be modularised. CloudWatch services and scaling code must be tested prior to submission)

[Terraform Code](terraform)

In the Terraform script, there are 2 part,
1. The first part is the module Infrastructure Require to run the app
2. The second part is the helm release resource to install necessary tool for integration
> **_NOTE:_**  In the first run please command all the helm release resource and helm provider. Sorry for this inconvient since I have limited time so the structure might not be good enough

Test Result for Autoscale

![img.png](img.png)

> **_NOTE:_**  In the picture above I just want to show that I'm able to autoscale the node when I run the jenkins pipeline.

### Item 3 The below Kubernetes artifacts that are required to deploy the application

[Weather App](k8s-manifest/weatherapp)

> **_NOTE:_**  The nginx ingress was defined in the terraform main.tf using helm release resource

### Item 4 Jenkins pipeline script to deploy application(s) into the Kubernetes cluster
[Jenkins Pipeline](jenkins)

### Item 5 Application API deployed into AWS API gateway

![img_1.png](img_1.png)
I created VPN Link cause the LB is internal
![img_4.png](img_4.png)
### Item 6 Working postman script to demonstrate the API with proper authentication

1. With Authorization
![img_2.png](img_2.png)

2. Without Authorization
![img_3.png](img_3.png)