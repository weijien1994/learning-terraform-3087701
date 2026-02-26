# define data block 
# ami image data block below
data "aws_ami" "app_ami" {                      #  defined base image ID
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

# vpc data block below 
data "aws_vpc" "default" {                       # defined vpc ID
  default = true
}



# define cloud resources
# aws instance resource below
resource "aws_instance" "blog" {                 # aws_instance recourse with name "Blog" on terraform 
  ami           = data.aws_ami.app_ami.id        # Base image ID, refer to data block ID 
  instance_type = var.instance_type              # instance type refer to variable.tf 

  vpc_security_group_ids = [aws_security_group.blog.id]     # array provide list of secuirty group

  tags = {
    Name = "HelloWorld"
  }
}

# aws security group resource below
resource "aws_security_group" "blog" {        
  name        = "blog"
  description = "Allow http and https in, Allow everything out" 

  vpc_id = data.aws_vpc.default.id               # vpc id refer to data block ID     
}

# aws security group resource rule below
resource "aws_security_group_rule" "blog_http_in" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type      = "egress"
  from_port = 0
  to_port   = 0 
  protocol  = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}


# module
module "blog_sg" {                                                 #define module code name
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"   # define module path/location
  version = "5.3.1" 
  name = "blog_new"

  vpc_id = data.aws_vpc.default.id

  ingress_rules          = ["http-80-tcp","https-443-tcp"]          # refer to module doc for condiguration
  ingress_cidr_blocks    = ["0.0.0.0/0"]

  egress_rules           = [http-80-tcp","https-443-tcp"]
  egress_cidr_block      = ["0.0.0.0/0"]
}
