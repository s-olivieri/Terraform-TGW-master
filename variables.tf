variable "project_name" {
  description = "Project Name - will prefex all generated AWS resource names"
  default     = "Trend-Micro-TGW"
}

######################################
######## Account Settings ############
######################################

provider "aws" {
  #  shared_credentials_file = "~/.aws/credentials"
  #  shared_credentials_file = "%USERPROFILE%\.aws\credentials"
  /*
      Shared credential files is a text file with the following format:
        [<PROFILE>]
        aws_access_key_id = <ACCESS_KEY_ID>
        aws_secret_access_key = <SECRET_ACCESS_KEY
  */
  profile = "default"
  region  = var.region
  #version = "~> 2.61.0"
}

variable "region" {
  default = "ap-southeast-2"
}

data "aws_availability_zones" "azs" {
}

# Private key
variable "key_name" {
  description = "Must be the name of an existing EC2 KeyPair"
  default     = "KeyPairAUSVPC"
}

#########################################
############# Topology ##################
#########################################


# internet VPC
variable "internet_cidr_vpc" {
  description = "Trend Micro internet VPC"
  default     = "10.30.0.0/16"
}
variable "internet_cidr_2_vpc" {
  description = "Trend Micro internet VPC"
  default     = "10.30.0.32/28"
}

variable "egress_private_cidr_vpc" {
  description = "Trend Micro internet VPC secondary IP"
  default     = "10.31.0.0/16"
}

# VPC hosting out private facing website
variable "spoke_1_cidr_vpc" {
  description = "VPC hosting an internet facing website"
  default     = "10.110.0.0/16"
}

# VPC hosting second website
variable "spoke_1a_cidr_vpc" {
  description = "VPC hosting an internet facing website"
  default     = "10.111.0.0/16"
}

# VPC hosting a test endpoint
variable "spoke_2_cidr_vpc" {
  description = "VPC hosting a Linux testing server - no inbound access"
  default     = "10.120.0.0/16"
}

variable "spoke_1_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9080"
}

variable "app_1_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9081"
}

variable "app_2_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9082"
}

###########################################
############# Server Settings #############
###########################################
# Hashed password for the Trend Micro servers - you can generate this with the command 'openssl passwd -1 <PASSWORD>'
# (Optional) You can instead SSH into the server and run (from clish): 'set user admin password', fowlloed by 'save config'


variable "linux_small_server_size" {
  default = "t2.micro"
}

#############################################
######### Trend Micro Template Names ########
#############################################



variable "internet_configuration_template_name" {
  description = "The name of the internet template name in the cloudformation template"
  default     = "tgw-internet-template"
}



variable "externaldnshost" {
  description = "The name of the first website"
  default     = "www"
}

variable "externaldnshostapp" {
  description = "The name of the second website"
  default     = "app"
}

variable "r53zone" {
  description = "The name of the domain used"
  default     = "mycloud.net"
}

