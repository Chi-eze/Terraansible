provider "aws" {
  region = "${ var.aws_region}"
  profile = "${ var.aws_profile }"

}

# Getting IAM 
#s3_access

#VPC 

resource "aws_vpc" "skies_vpc" {
  cider_block = " 10.1.0.0.16/16"
}

# Internet Gate way

resource "aws_internet_gateway" "skies_internet_gateway" {
  vpc_id = "${ aws_vpc.skies_vpc.id }"
}
#Public route table

resource "aws_route_table"  " public" {

   vpc_id = "${ aws_vpc.skies_vpc.id }"
   route { 
          cidr_block = "0.0.0.0/0"
          gateway_id = "{ aws_internet_gateway.skies_gateway.id }"
    tags {
          Name = "public"
    }
   }
}


#Private route table

resource  "aws_defualt_route_table "  "private" {
  default_route_table_id = "${ aws_vpc.skies_vpc.defult_route_table.id }"
  tags {
    Name = "private"
  }
}
#subnets
#public subnet
 resource "aws_subnet" "public" {
   vpc_id ="${ aws_vpc.skies_vpc.id }"
   cidr_block = " 10.1.1.0/24 "
   map_public_ip_on_launch = true 
   availability_zone = "eu-west-1d"
   tags {
     Name ="public"
   }

 }

#Private 1

resource "aws_subnet" " private1" {
  vpc_id = "${ aws_vpc.skies_vpc.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1a"
  tags {
    Name ="private1"
  }
# Private 2

resource "aws_subnet" " private2 " {
  vpc_id ="${ aws_vpc.skies_vpc.id }"
  cider_block = " 10.0.1.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1c"

  tags{
    Name = "private2"
  }
  
}
 

# RDS sub net group < RDS-1 RDS -2 RDS -3 >

resource "aws_subnet" "rds1" {
  vpc_id = "${ aws_vpc.skies_vpc.id }"
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1a"

  tags {
    Name = "rds1"
    }
}

#RDS -2
resource "aws_subnet" " rds2" {
  vpc_id = "${ aws_vpc.skies_vpc.id }"
  cidr_block = " 10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1c"

  tags {
    Name = "rds2"
  }
}
#RDS -3

resource "aws_subnet" "rds3" {
  vpc_id = "${ aws_vpc.skies_vpc.id }"
  cider_block = "10.0.1.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1d"
}



# Associate subnet with routing tabel  >



#Public
resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${ aws_subnet.public}" 
  route_table_id ="${ aws_route_table.public.id }"

  tags{
    Name = "skies_public_route_table"
  }
}

#Privgate 

resource "aws_route_table_association" "private1_assoc" {
  subnet_id = "${ aws_subnet.private1.id}" 
  route_table_id ="${ aws_route_table.private1.id}"

  tags {
    Name = "skies_private1_route_table"
  }
  
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id = "${ aws_subnet.private2.id }"
  route_table_id = "${ aws_route_table.private2.id }"

  tags {
    Name = " Skies_private1_route_table" 

  }
  
}

resource "aws_db_subnet_group" "rds_subnetgroup" {

  name = "rds_subnetgroup"
  subnet_ids = ["${ aws_subnet.rds1.id }" ,"${ aws_subnet.rds2.id }" ,"${ aws_subnet.rds3.id }"]

tags {
  Name = "rds_sng"
}
  
}

# Security Group

resource  "aws_security_group" "public" {
  name = "sg_public"
  description = "used for both private and public instances for load balancer access "
  vpc_id = "${ aws_vpc.skies_vpc.id }"
  #SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${ var.localip }" ]
  }

# HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cider_blocks =  [ "0.0.0.0/0 "]
    
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

  }

}
  
# Private security Group

resource "aws_security_group" "private" {
  name = "sg_private"
  description = "used for private instances"
  vpc_id = "$ { aws_vpc.skies_vpc.id }"

  # Acess from other security group

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.0.0/16"] 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0 /0 "]
  }

}
  
#RDS security Group


resource "aws_security_group" "RDS" {
  name = "sg_rds"
  description = "used for DB instances"
  vpc_id = "${ aws_vpc.skies_vpc.id}"

  #SQL access from public / private security group

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
   security_groups = ["${aws_security_group.public}" ,  "${ aws_security_group.private.id }"]


  }
}





#S3 Code Bucket

#Compute
#Key Pair 
#Dev Sever 
  # ansible play
#Load balancer 
# AMI
# Lunch configuration
# Auto scaling group

# Route53 
# primary zone : use deligation set 
#www point to load balancer 
#dev record to point to the dev server public IP address 
#db cname for RDS < allow web server to point to the RDs even if the IP changes 