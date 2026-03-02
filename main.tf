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

  owners = ["979382823631"]               
}

# vpc data block below 
# data "aws_vpc" "default" {                       # defined vpc ID
#   default = true
# }



# define cloud resources or module 
# aws vpc module recourse below 
module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# aws instance resource below
resource "aws_instance" "blog" {                 # aws_instance recourse with name "Blog" on terraform 
  ami           = data.aws_ami.app_ami.id        # Base image ID, refer to data block ID 
  instance_type = var.instance_type              # instance type refer to variable.tf 

  vpc_security_group_ids = [module.blog_sg.security_group_id]     # Add SG group ID to instance, SG Group ID reference to terraform module doc output var

  subnet_id = module.blog_vpc.public_subnets[0]                   # add module vpc ip to instance

  tags = {
    Name = "HelloWorld"                          # add tag to instance 
  }
}

# aws security group resource below
resource "aws_security_group" "blog" {           # Resource = SG, SG name on terraform console = blog (Create new SG Group)
  name        = "blog"                           # SG name in aws console = blog
  description = "Allow http and https in, Allow everything out" 

  vpc_id = module.blog_vpc.vpc_id               # add vpc module id to SG group      
}

# aws security group modules resource below configuration (define modules and leverage on existing module from tarraform/aws) 
module "blog_sg" {                                                 # define module code name in terraform
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"   # define module source/path/location
  version = "5.3.1" 
  name = "blog_new"                                                # name in aws console

  vpc_id = module.blog_vpc.vpc_id

  ingress_rules          = ["http-80-tcp","https-443-tcp"]          # refer to module doc for condiguration
  ingress_cidr_blocks    = ["0.0.0.0/0"]

  egress_rules           = ["all-all"]
  egress_cidr_blocks     = ["0.0.0.0/0"]
}

# aws security group resource rule below
resource "aws_security_group_rule" "blog_http_in" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id          # add SG rule to security group
}

resource "aws_security_group_rule" "blog_https_in" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id          # add SG rule to security group
}

resource "aws_security_group_rule" "blog_everything_out" {
  type      = "egress"
  from_port = 0
  to_port   = 0 
  protocol  = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id          # add SG rule to security group
}

# aws ALB module resource below
module "blog_alb" {                                       # name module in terraform
  source = "terraform-aws-modules/alb/aws"

  name    = "blog-alb"                                    # alb name in aws
  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets

  security.groups = [module.blog_sg.security_group_id]    # add SG to ALB

  listeners = {
    blog-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_arn = aws_lb_target.group.blog.arn 
      }
    }

  tags = {
    Environment = "dev"
  }
}
