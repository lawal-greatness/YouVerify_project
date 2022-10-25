#create vpc 
resource "aws_vpc" "You_verify" {
  cidr_block       = var.You_verify
  instance_tenancy = "default"

  tags = {
    Name = "You_verify"
  }
}

#create subnets
resource "aws_subnet" "SnPub1" {
  vpc_id            = aws_vpc.You_verify.id
  cidr_block        = var.SnPub1
  availability_zone = "us-west-1a"

  tags = {
    "Name" = "SnPub1"
  }
}

resource "aws_subnet" "SnPri1" {
  vpc_id            = aws_vpc.You_verify.id
  cidr_block        = var.SnPri1
  availability_zone = "us-west-1a"

  tags = {
    "Name" = "SnPri1"
  }
}

resource "aws_subnet" "SnPub2" {
  vpc_id            = aws_vpc.You_verify.id
  cidr_block        = var.SnPub2
  availability_zone = "us-west-1b"

  tags = {
    "Name" = "SnPub2"
  }
}
resource "aws_subnet" "SnPri2" {
  vpc_id            = aws_vpc.You_verify.id
  cidr_block        = var.SnPri2
  availability_zone = "us-west-1b"

  tags = {
  "Name" = "SnPri2" }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.You_verify.id
  tags = {
    Name = "igw"
  }
}

# Create Elastic IP
resource "aws_eip" "youverify_eip" {
  vpc = true

  tags = {
    Name = "youverify_eip"
  }
}

#create NAT gateway 
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.youverify_eip.id
  subnet_id     = aws_subnet.SnPub1.id
  tags = {
    Name = "ngw"
  }
}

#create route table public 
resource "aws_route_table" "youverify_RT1" {
  vpc_id = aws_vpc.You_verify.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#create route table private 
resource "aws_route_table" "youverify_RT2" {
  vpc_id = aws_vpc.You_verify.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

# Create Route Table Association for Public Subnet1
resource "aws_route_table_association" "SnPub1_association1" {
  subnet_id      = aws_subnet.SnPub1.id
  route_table_id = aws_route_table.youverify_RT1.id
}
# Create Route Table Association for Public Subnet2
resource "aws_route_table_association" "SnPub2_association2" {
  subnet_id      = aws_subnet.SnPub2.id
  route_table_id = aws_route_table.youverify_RT1.id
}
# Create Route Table Association for Private Subnet1
resource "aws_route_table_association" "SnPri1_association3" {
  subnet_id      = aws_subnet.SnPri1.id
  route_table_id = aws_route_table.youverify_RT2.id
}

# Create Route Table Association for Private Subnet2
resource "aws_route_table_association" "SnPri2_association4" {
  subnet_id      = aws_subnet.SnPri2.id
  route_table_id = aws_route_table.youverify_RT2.id
}


#Create security groups for all server

#Security group for jenkins servers (Allows proxy and ssh)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.You_verify.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins_sg"
  }
}

#Security group for sonarqube servers
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.You_verify.id
  ingress {
    description = "sonarqube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sonarqube"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sonarqube_sg"
  }
}
#Security group for mysql servers
resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "Allow mysql traffic"
  vpc_id      = aws_vpc.You_verify.id
  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1, var.SnPub2]
  }
  ingress {
    description = "Allow mysql traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1, var.SnPub2]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysql_sg"
  }
}

#create database subnet group
resource "aws_db_subnet_group" "db_sn_group" {
  name       = "youverify_db_sn_group"
  subnet_ids = [aws_subnet.SnPri1.id, aws_subnet.SnPri2.id]

  tags = {
    Name = "youverify_db_sn_group"
  }
}

#Create MySQL RDS Instance
resource "aws_db_instance" "Youverify_RDS" {
  identifier             = "database"
  storage_type           = "gp2"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.aws_instance_class
  port                   = "3306"
  db_name                = "PAADEU2"
  username               = var.database_username
  password               = var.db_passward
  multi_az               = true
  parameter_group_name   = "default.mysql8.0"
  deletion_protection    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_sn_group.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
}

#Create key pair for server
resource "aws_key_pair" "PAADEU2" {
  key_name   = "PAADEU2"
  public_key = file(var.test)
}

# Create the Jenkins Instance
resource "aws_instance" "jenkins_server" {
  ami                         = var.ami_redhat
  instance_type               = var.aws_instance_type
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  subnet_id                   = aws_subnet.SnPub1.id
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data_replace_on_change = true
     user_data                   = <<-EOF


  #!/bin/bash
  sudo yum update -y
  sudo yum install wget -y
  sudo yum install git -y
  sudo curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
  sudo yum install nodejs -y
  sudo wget http://get.jenkins.io/redhat/jenkins-2.346-1.1.noarch.rpm
  sudo rpm -ivh jenkins-2.346-1.1.noarch.rpm
  sudo yum upgrade -y
  sudo yum install jenkins java-11-openjdk-devel -y --nobest
  sudo yum install epel-release java-11-openjdk-devel
  sudo systemctl daemon-reload
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  echo "license_key:eu01xx077bfebecb4a23bb2805b13c17cbd8NRAL" | sudo tee -a /etc/newrelic-infra.yml
  sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
  sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
  sudo yum install newrelic-infra -y
  sudo hostnamectl set-hostname Jenkins

  
EOF 
 
  
  tags = {
    Name = "jenkins_server"
  }
}



# SonarQube Server
resource "aws_instance" "sonarqube_server" {
  ami                         = var.ami_ubuntu
  instance_type               = var.aws_instance_type
  subnet_id                   = aws_subnet.SnPub1.id
  vpc_security_group_ids      = [aws_security_group.sonarqube_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF



#!bin/bash
sudo apt-get update
sudo hostnamectl set-hostname SonarQube
sudo apt-get install openjdk-11-jdk -y
echo "license_key: eu01xx077bfebecb4a23bb2805b13c17cbd8NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo su - postgres
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'youverify';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;
\q
exit
sudo apt-get install unzip -y
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.6.0.39681.zip
sudo unzip sonarqube*.zip -d /opt
sudo mv /opt/sonarqube-8.6.0.39681 /opt/sonarqube -v
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
sudo cat <<EOT>> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=youverify
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
EOT
sudo cat <<EOT>> /opt/sonarqube/bin/linux-x86-64/sonar.sh
RUN_AS_USER=sonar
EOT
sudo cat <<EOT> /etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl enable sonar
sudo systemctl start sonar
sudo cat <<EOT>> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT
sudo reboot
tail -f /opt/sonarqube/logs/sonar*.log
   EOF 
  tags = {
    Name = "Sonarqube_Server"
  }


}