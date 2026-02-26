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



# Identify cloud resources nameing and details
resource "aws_instance" "blog" {                 # aws_instance recourse with name "Blog" on terraform 
  ami           = data.aws_ami.app_ami.id        # Base image to use, dynamic id/data reference top 
  instance_type = var.instance_type              # instance type gether from variable.tf 

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow http and https in, Allow everything out" 

  vpc_id = data.aws_vpc.default.id
}
