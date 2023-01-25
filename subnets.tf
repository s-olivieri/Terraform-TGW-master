##########################################
########### Management VPC  ##############
##########################################

# Create subnets to launch our instances into

########################################
########### internet VPC  ##############
########################################

resource "aws_subnet" "internet_subnet" {
  vpc_id            = aws_vpc.internet_vpc.id
  cidr_block        = var.internet_cidr_2_vpc

  tags = {
    Name = "${var.project_name}-Internet"
  }

}

resource "aws_subnet" "egress_private_subnet" {
  vpc_id            = aws_vpc.internet_vpc.id
  cidr_block        = var.egress_private_cidr_vpc

  tags = {
    Name = "${var.project_name}-Egress-Private"
  }

}

#data "aws_subnet" "internet_subnet" {
#  count = length(data.aws_availability_zones.azs.names)
#   id    = data.aws_subnet_ids.internet_subnet_ids.ids[count.index]
#    id    = tolist(data.aws_subnet_ids.internet_subnet_ids.ids)[count.index]

#}

# -    subnet_ids         = ["${data.aws_subnet_ids.private.ids[0]}", "${data.aws_subnet_ids.private.ids[1]}"]
# +    subnet_ids         = "${slice(data.aws_subnet_ids.private.ids, 0, 1)}"


#####################################
########### Spoke-1 VPC  ############
#####################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_1_external_subnet" {
  #count             = length(data.aws_availability_zones.azs.names)
  #availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.spoke_1_vpc.id
  cidr_block        = var.spoke_1_cidr_vpc

  tags = {
    Name = "${var.project_name}-Spoke-1-External"
  #cidr_block        = cidrsubnet(var.spoke_1_cidr_vpc, 8, count.index + 100)

  #tags = {
    #Name = "${var.project_name}-Spoke-1-External-${count.index + 1}"
  }
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_2_external_subnet" {
  vpc_id     = aws_vpc.spoke_2_vpc.id
  cidr_block = var.spoke_2_cidr_vpc

  tags = {
    Name = "${var.project_name}-Spoke-2-External"
  }
}

#####################################
########### Spoke-1a VPC  ############
#####################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_1a_external_subnet" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.spoke_1a_vpc.id
  cidr_block        = cidrsubnet(var.spoke_1a_cidr_vpc, 8, count.index + 100)

  tags = {
    Name = "${var.project_name}-Spoke-1a-External-${count.index + 1}"
  }
}

