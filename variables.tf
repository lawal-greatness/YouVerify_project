#Vpc  
variable "You_verify" {
  default = "10.0.0.0/16"
}
#Public Subnet 1
variable "SnPub1" {
  default = "10.0.1.0/24"
}

#Public Subnet 2
variable "SnPub2" {
  default = "10.0.3.0/24"
}

#Private Subnet 1
variable "SnPri1" {
  default = "10.0.2.0/24"
}

#Private Subnet 2
variable "SnPri2" {
  default = "10.0.4.0/24"
}

variable "aws_instance_class" {
  default = "db.t2.medium"
}

variable "database_username" {
  default = "Admin"
}

variable "db_passward" {
  default = "Admin123"
}

#private keypair
variable "test" {
  default = "/Users/apple/Desktop/Hello/Youverify_project/YouVerify_project/sshkey.pub"
}

variable "ami_redhat" {
  default = "ami-0186e3fec9b0283ee"
}

variable "aws_instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "PAADEU2"
}



variable "ami_ubuntu" {
  default = "ami-02ea247e531eb3ce6"
}



