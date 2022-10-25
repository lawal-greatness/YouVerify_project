# YouVerify_project
This is a project for a hiring process

For this project, AWS infrastructure was provisioned
VPC, private and public subnets
Internet Gateway, Elastic IP, NAt gateway
Public and private route tables with rouute table associationfor the subnets
Security groups for servers opening all needed ports for security 
creation of database subnet group and MySQL RDS instance
Keypair for ssh
Jenkins server
SonarQube server

The CI/CD tools used is jenkins and nodejs was installed on it to create a pipeline for the deployment of the app on the app repo.
Newrelic is install on jenkins server to monitor the instances running on the pipeline

SOnarqube is also installed on an ubuntu server to analys the codes
