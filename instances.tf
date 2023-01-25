# Create ubuntu instances for the websites (user ubuntu) 
#data "aws_ami" "ubuntu" {
  #most_recent = true
  #filter {
    #name   = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  #}

  #filter {
    #name   = "virtualization-type"
    #values = ["hvm"]
  #}

  #owners = ["099720109477"] # Canonical
#}

#############################################
########### Spoke-1 Web Server  ##############
#############################################

locals {
  website = <<WEBSITE
sudo echo "" > index.html
sudo echo "Greetings!" >> index.html
sudo echo "----------" >> index.html
sudo echo "" >> index.html
sudo echo "This is a web server in Spoke-1!" >> index.html
sudo echo "" >> index.html
sudo nohup busybox httpd -f -p 80 &
sudo sleep 5
WEBSITE

}

resource "aws_instance" "spoke_1_instance" {
  ami                         = "ami-06bb074d1e196d0d4"
  instance_type               = var.linux_small_server_size
  iam_instance_profile        = aws_iam_instance_profile.resources-iam-profile.name
  #count                       = length(data.aws_availability_zones.azs.names)
  #availability_zone           = element(data.aws_availability_zones.azs.names, count.index)
  subnet_id                   = aws_subnet.spoke_1_external_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.spoke_1_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "${local.website}" >> website.sh
              chmod +x website.sh
              mv ./website.sh /home/ubuntu/
              sudo echo "" > index.html
              sudo echo "Greetings!" >> index.html
              sudo echo "-----App1-----" >> index.html
              sudo echo "" >> index.html
              sudo echo "This is a web server in App1!" >> index.html
              sudo echo "" >> index.html
              sudo mkdir app1
              sudo echo "Web server directed by /app1" >> app1/index.html
              sudo nohup busybox httpd -f -p 80 &
              sudo sleep 5
EOF


  tags = {
    Name   = "${var.project_name}-Spoke-1 Linux"
    Server = "${var.project_name}-Website"
    SSM-Agent   = "true"
  }
}


#############################################
######## Spoke-1a app2 Web Server  ##########
#############################################

resource "aws_instance" "spoke_1a_instance" {
  ami                         = "ami-06bb074d1e196d0d4"
  instance_type               = var.linux_small_server_size
  count                       = length(data.aws_availability_zones.azs.names)
  availability_zone           = element(data.aws_availability_zones.azs.names, count.index)
  subnet_id                   = element(aws_subnet.spoke_1a_external_subnet.*.id,count.index)
  iam_instance_profile        = aws_iam_instance_profile.resources-iam-profile.name
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.spoke_1a_security_group.id]

    user_data = <<-EOF
              #!/bin/bash
              echo "${local.website}" >> website.sh
              chmod +x website.sh
              mv ./website.sh /home/ubuntu/
              sudo echo "" > index.html
              sudo echo "Greetings!" >> index.html
              sudo echo "-----app2-----" >> index.html
              sudo echo "" >> index.html
              sudo echo "This is a web server in ${element(data.aws_availability_zones.azs.names, count.index)}!" >> index.html
              sudo echo "" >> index.html
              sudo mkdir app2
              sudo echo "Web server directed by /app2" >> app2/index.html
              sudo nohup busybox httpd -f -p 80 &
              sudo sleep 5
              EOF

  tags = {
    Name        = "${var.project_name}-Spoke-1a Web Server ${count.index+1}"
    Server      = "${var.project_name}-Website"
    SSM-Agent   = "true"
  }
}

/*
######################################
########### Spoke-1a client ###########
######################################

resource "aws_instance" "spoke_1a_instance" {
  ami                         = "ami-06bb074d1e196d0d4"
  instance_type               = var.linux_small_server_size
  subnet_id                   = aws_subnet.spoke_1a_external_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.spoke_1a_security_group.id]

  tags = {
    Name      = "${var.project_name}-Spoke-1a Linux"
    Dev-Test  = "false"
    Prod-Test = "true"
  }
}
*/

######################################
########### Spoke-2 client ###########
######################################

resource "aws_instance" "spoke_2_instance" {
  ami                         = "ami-06bb074d1e196d0d4"
  instance_type               = var.linux_small_server_size
  subnet_id                   = aws_subnet.spoke_2_external_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.resources-iam-profile.name
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.spoke_2_security_group.id]

  tags = {
    Name      = "${var.project_name}-Spoke-2 Linux"
    Dev-Test  = "false"
    Prod-Test = "true"
    SSM-Agent = "true"
  }
}

######################################
###########    Jump Host    ##########
######################################

resource "aws_instance" "jump_host_instance" {
  ami                         = "ami-06bb074d1e196d0d4"
  instance_type               = var.linux_small_server_size
  subnet_id                   = aws_subnet.internet_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.resources-iam-profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.internet_security_group.id]

  tags = {
    Name      = "${var.project_name}-Jump Host Linux"
    Dev-Test  = "false"
    Prod-Test = "true"
    SSM-Agent = "true"
  }
}
