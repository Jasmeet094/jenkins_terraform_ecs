# Jenkins Master-Slave Setup with ECS using Terraform
This repository contains Terraform code to set up a Jenkins Master-Slave architecture using Amazon ECS (Elastic Container Service). The master Jenkins server is deployed as an ECS service, while the slave (worker) Jenkins agents are spun up dynamically as ECS tasks when a Jenkins job is triggered.

### Project Overview
The project is designed to leverage Infrastructure as Code (IaC) through Terraform to automate the deployment of Jenkins on ECS with a Fargate launch type. It uses Jenkins Configuration as Code (JCasC) to configure Jenkins with predefined settings, jobs, views, and agents.

### Key Features:
Jenkins is deployed as an ECS service, with Docker image builds and pushes automated through Terraform.
ECS is used to dynamically create Jenkins slave agents (Fargate workers) that execute Jenkins jobs.
The setup is fully modular, following best practices in Terraform to manage components such as ECS clusters, load balancers, and ECR.
The configuration of Jenkins is managed by JCasC for consistency and ease of reproduction.

### What’s Inside?
The repository structure follows a modular approach in Terraform, making it reusable and scalable.

```sh
- modules - this folder contains all the Child Modules for AWS Services
- deploy_jenkins_terraform - This folder contains the Root Module for terraform and `jenkins.tfvar` file.
```

### Key Components
Jenkins Master-Slave Architecture
This setup involves deploying a Jenkins master server in ECS Cluster named Master Cluster and creating Jenkins slaves (workers) as Fargate tasks dynamically in AWS ECS Cluster named Worker_Cluster. When a Jenkins job is triggered, it uses a slave agent spun up in ECS, which terminates once the job is complete.


### Jenkins Configuration as Code (JCasC)
The Jenkins Configuration as Code (JCasC) approach allows you to configure Jenkins using YAML files.This file. is responsible for deploying the Jenkins server with predefined configuration using terraform. In the Modules/aws-ecr/docker/files/jenkins.yaml.tftpl file is present. This file is the Jenkins configuraion file. During terraform apply this file. is processed by terraform and stored in this folder as jenkins.yaml file using terraform null_resource. During Docker image creation this file is copied to the jenkins server. Creation of docker image ,  jenkins configuration is all handled in ECR main.tf. In the jenkins.yaml JCASC file we are creating 1 Cloud in jenkins and for this cloud we are using the ECS worker Cluster. After the jenkins deployed it will comes up with 2 predefined example jobs created and when we run these jobs a ECS task will be run in ECS Cluster worker_cluster. Jenkins server username is ecsuser and for the password variable `JENKINS_ADMIN_PWD` is used in the JCASC file. First we need to create a secret with same name `JENKINS_ADMIN_PWD` and we can use any value for password and then we need to reference this password as Secret to the Container Definition. In this way the password for the Jenkins server value is available to the main container all the time.



### How to Use
* Prerequisites
```
1. Change the values as per your requirements in jenkins.tfvars
2. In the folder deploy_jenkins_terraform/main.tf in the end change the value for the record name.
3. Create a Seceret in AWS Seceret Manger with Name `JENKINS_ADMIN_PWD` and update the ARN of this secret in jenkins.tfvars for secrets.
4. Create Required Certificate for the Domain name in AWS Certificate Manager and Hosted Zone in AWS Route53

```

### This project provides a scalable, modular solution for setting up Jenkins in a master-slave architecture on AWS ECS. It leverages best practices such as Jenkins Configuration as Code and Terraform modules to ensure ease of use and flexibility.

Note: There are 2 folders here in this repository
```
1. ecs-jenkins-terraform - This Folder contains the Jenkins server code for password authentication and will setup with 2 pre-configured example jobs.

2. ecs-password-less-jenkins-terraform - This Folder contains the code if you want to create jenkins servers with pre-configured jobs and the authentication (traffic to ALB )is through VPN access. You can chnage the configurations for jobs in /modules/nclouds_tf_ecr/docker/files/jobs.groovy file. and to change the VPN Ip in jenkins.tfvars under variable `vpn_ip`. The SG of ALB has access for all traffic though this variable (VPN IP) 
```

## Roadmap
- [x] Check below content
- [ ] Add Changelog
- [ ] Add back to top links
- [ ] Add Additional Templates w/ Examples
- [ ] Add "components" document to easily copy & paste sections of the readme
- [ ] Multi-language Support
    - [ ] Chinese
    - [ ] Spanish


