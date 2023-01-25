##########################################
########### Internet VPC  ################
##########################################

#data "aws_vpc" "data_internet_asg_vpc" {
#  filter {
#    name   = "tag:Name"
#    values = ["${var.project_name}-Internet-ASG-VPCStack-*"]
#  }
#  depends_on = [aws_cloudformation_stack.checkpoint_tgw_cloudformation_stack]
#}

resource "aws_vpc" "internet_vpc" {
  cidr_block           = var.internet_cidr_vpc
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}-Internet-VPC"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "egress_private_subnet" {
  vpc_id            = aws_vpc.internet_vpc.id
  cidr_block        = var.egress_private_cidr_vpc

}

# A security group to give access via the web
resource "aws_security_group" "internet_security_group" {
  vpc_id = aws_vpc.internet_vpc.id

  # Full tester inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Internet-SG"
  }
}

######################################
########### Spoke-1 VPC  #############
######################################

# Create a test VPC and launch a public facing web server
resource "aws_vpc" "spoke_1_vpc" {
  cidr_block           = var.spoke_1_cidr_vpc
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}-Spoke-1-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_1_security_group" {
  vpc_id = aws_vpc.spoke_1_vpc.id

  # Full tester inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Spoke-1-SG"
  }
}

######################################
########### Spoke-1a VPC  #############
######################################

# Create a test VPC and launch a second public facing web server
resource "aws_vpc" "spoke_1a_vpc" {
  cidr_block           = var.spoke_1a_cidr_vpc
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}-Spoke-1a-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_1a_security_group" {
  vpc_id = aws_vpc.spoke_1a_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Spoke-1a-SG"
  }
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create a test VPC to launch a testing linux host 
resource "aws_vpc" "spoke_2_vpc" {
  cidr_block           = var.spoke_2_cidr_vpc
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}-Spoke-2-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_2_security_group" {
  vpc_id = aws_vpc.spoke_2_vpc.id

  # Full tester inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Spoke-2-SG"
  }
}

