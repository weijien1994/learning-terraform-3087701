data "aws_ami" "app_ami" {
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


# Identify cloud resources nameing and details
resource "aws_instance" "blog" {                 # aws_instance recourse with name "Blog" on terraform 
  ami           = data.aws_ami.app_ami.id        # ami ID gather from top data
  instance_type = var.instance_type              # instance type gether from variable.tf 

  tags = {
    Name = "HelloWorld"
  }
}
