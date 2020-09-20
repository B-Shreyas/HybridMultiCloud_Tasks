### provider and profile ###

provider "aws" {
  region = "ap-south-1"
}


### Vpc created ###


resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Shreyas_vpc"
  }
}
resource "aws_internet_gateway" "ShreyasGateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "shreyas_gateway"
  }
}

### Public Subnet created ###

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "shreyas_subnet_public"
  }
}


### Private Subnet created ###

resource "aws_subnet" "privatesubnet" {
    vpc_id = aws_vpc.main.id

    cidr_block = "192.168.1.0/24"
    availability_zone = "ap-south-1b"

  tags = {
    Name = "shreyas_subnet_private"
  }
}

### Routing Table created ###

resource "aws_route_table" "shreyas_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ShreyasGateway.id
  }

  tags = {
    Name = "shreyas_routetable"
  }
}


resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.shreyas_table.id
}

### Web security firewalls created ###


resource "aws_security_group" "mywebsecurity" {
  name        = "my_web_security"
  description = "Allow HTTP,SSH,ICMP"
  vpc_id      =  aws_vpc.main.id

  ingress {
    description = "HTTP"
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
 ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mywebserver_sg"
  }
} 

### WordPress instance ###

resource "aws_instance" "wordpress" {
  ami           = "ami-000e4324711d48e58"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.publicsubnet.id
  vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
  key_name = "task3"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "wordpress"
  }

}

### MySql instance ###

resource "aws_instance" "mysql" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.privatesubnet.id
  vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
  key_name = "task3"
  availability_zone = "ap-south-1b"

 tags = {
    Name = "mysql"
  }

}


