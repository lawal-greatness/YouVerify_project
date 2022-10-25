# Configure the AWS Provider
provider "aws" {
  region                   = "us-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}