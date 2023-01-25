##########################################
########### Internet VPC  ################
##########################################


# Create an internet gateway to give internet access
resource "aws_internet_gateway" "internet_internet_gateway" {
  vpc_id = aws_vpc.internet_vpc.id

  tags = {
    Name = "${var.project_name}-Internet-IGW"
  }
}

# Create Internet route tables
resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.internet_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_internet_gateway.id
  }

  # Routes to Spokes
  route {
    cidr_block         = var.spoke_1_cidr_vpc
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }
  route {
    cidr_block         = var.spoke_1a_cidr_vpc
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }
  route {
    cidr_block         = var.spoke_2_cidr_vpc
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }

  tags = {
    Name = "${var.project_name}-Internet-Route-Table"
  }
}
resource "aws_route_table_association" "internet_table_association" {
  subnet_id      = aws_subnet.internet_subnet.id
  route_table_id = aws_route_table.internet_route_table.id
  #transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.internet_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = {
    Name = "${var.project_name}-NAT-GW"
    }
  
}

resource "aws_route_table_association" "nat_table_association" {
  subnet_id      = aws_subnet.egress_private_subnet.id
  route_table_id = aws_route_table.nat_route_table.id
  
}

#data "aws_route_table" "data_internet_asg_route_table" {
#  filter {
#    name   = "tag:aws:cloudformation:stack-name"
#    values = ["${var.project_name}-internet-ASG-VPCStack-*"]
#  }

  #depends_on = [aws_cloudformation_stack._tgw_cloudformation_stack]
#}

# Route to the Management VPC - Control channel through a VPC attachment, not through the VPN tunnels
#resource "aws_route" "internet_to_management_route" {
#  route_table_id         = data.aws_route_table.data_internet_asg_route_table.id
#  destination_cidr_block = var.management_cidr_vpc
#  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
#}

######################################
########### Spoke-1 VPC  #############
######################################

# Create a route table
resource "aws_route_table" "spoke_1_route_table" {
  vpc_id = aws_vpc.spoke_1_vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }

  tags = {
    Name = "${var.project_name}-Spoke-1-Route"
  }
}

resource "aws_route_table_association" "spoke-1_route_table_association" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.spoke_1_external_subnet.*.id, count.index)
  route_table_id = aws_route_table.spoke_1_route_table.id
}

######################################
########### Spoke-1a VPC  #############
######################################

# Create a route table (default to TGW)
resource "aws_route_table" "spoke_1a_route_table" {
  vpc_id = aws_vpc.spoke_1a_vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }

  tags = {
    Name = "${var.project_name}-Spoke-1a-Route"
  }
}

resource "aws_route_table_association" "spoke-1a_route_table_association" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.spoke_1a_external_subnet.*.id, count.index)
  route_table_id = aws_route_table.spoke_1a_route_table.id
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create/Update routes
resource "aws_route_table" "spoke_2_route_table" {
  vpc_id = aws_vpc.spoke_2_vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }

  tags = {
    Name = "${var.project_name}-Spoke-2-Route"
  }
}

resource "aws_route_table_association" "spoke_2_route_table_association" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.spoke_2_external_subnet.id
  route_table_id = aws_route_table.spoke_2_route_table.id
}

###########################################################
######## Transit GW - Internet Spokes Route Table #########
###########################################################

# Create an route table for internet spoke-to-Internet traffic.
# This Route Table will be associated to spokes which are not exposed to the internet.
# It will handle all traffic from those spokes including spokes-to-Internet and spoke-to-spoke traffic
resource "aws_ec2_transit_gateway_route_table" "spoke_to_internet_transit_gateway_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  tags = {
    Name       = "${var.project_name}-TransitGW-internet-Spoke-Route-Table"
  }
}

# Create route association - Associate Internet VPC to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "internet_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
}
# Create route propagation - Add routes to the spoke VPCs
#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1_internet_transit_gateway_route_table_propagation" {
#transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id
#transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
#}

#Create route propagation - Add routes to the spoke VPCs
#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1a_internet_transit_gateway_route_table_propagation" {
#transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id
#transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
#}

#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_2_internet_transit_gateway_route_table_propagation" {
#transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id
#transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
#}

##########################################################
######## Transit GW - Inbound Spokes Route Table #########
##########################################################

# Create an route table for inbound Internet-to-spoke. 
# This Route Table is for spokes which are exposed to the Internet. 
# It will handle all traffic from those spokes including internet-to-spoke, spoke-to-internet and spoke-to-spoke
resource "aws_ec2_transit_gateway_route_table" "spoke_inbound_transit_gateway_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id

  # Routes for spoke-to-internet and spoke-to-spoke will be handled by the internet Security VPC
  # Those routes will be automatically provisioned by Management, based on the Route Table tags
  tags = {
    Name       = "${var.project_name}-TransitGW-Inbound-Spoke-Route-Table"
  }
}

# Create route association - Associate Spoke-1 to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_1_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id
}

# Create route association - Associate Spoke-1a to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_1a_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id
}

# Create route association - Associate Spoke-2 to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_2_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id
}

# Create route propagation - This is for replies to internet-to-spoke traffic
#resource "aws_ec2_transit_gateway_route_table_propagation" "_inbound_transit_gateway_route_table_propagation" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id
#}

#####################################
####### Transit GW routes ###########
#####################################

#Create static route associated to the TGW for External traffic
resource "aws_ec2_transit_gateway_route" "internet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id
}

#Create static route associated to the TGW for Spoke 1 traffic. Blackhole is out of scope for this route.
resource "aws_ec2_transit_gateway_route" "inbound_spoke-1" {
  destination_cidr_block         = "10.110.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
}

#Create static route associated to the TGW for Spoke 1a traffic. Blackhole is out of scope for this route.
resource "aws_ec2_transit_gateway_route" "inbound_spoke-1a" {
  destination_cidr_block         = "10.111.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
}

#Create static route associated to the TGW for Spoke 2 traffic. Blackhole is out of scope for this route.
resource "aws_ec2_transit_gateway_route" "inbound_spoke-2" {
  destination_cidr_block         = "10.120.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id
  
}
########################################################
##### Transit GW - internet Security Route Table #######
########################################################

# Create a route table for the internet VPC
#resource "aws_ec2_transit_gateway_route_table" "internet_transit_gateway_route_table" {
#  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id

  # Routes for spoke-to-internet and spoke-to-spoke will be handled by the internet Security VPC
  # Those routes will be automatically provisioned by Management, based on the Route Table tags
 # tags = {
 #   Name       = "${var.project_name}-TransitGW-internet-Route-Table"
 # }
#}

# Create route propagation - Add routes to the spoke VPCs
#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1_internet_transit_gateway_route_table_propagation" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table._internet_transit_gateway_route_table.id
#}

# Create route propagation - Add routes to the spoke VPCs
#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1a_internet_transit_gateway_route_table_propagation" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table._internet_transit_gateway_route_table.id
#}

#resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_2_internet_transit_gateway_route_table_propagation" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table._internet_transit_gateway_route_table.id
#}

#######################################################
##### Transit GW - Inbound Security Route Table #######
#######################################################



