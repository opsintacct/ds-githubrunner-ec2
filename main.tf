terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "xxxxx"
  region  = "us-west-2"
}

data "aws_vpc" "vpc"{
  id = var.vpc_id
}

data "aws_subnet_ids" "private_subnet_ids" {
      vpc_id      = data.aws_vpc.vpc.id
  tags = {
    Name = "*private*"
  }
}


resource "aws_security_group" "security_group" {
  vpc_id       =  data.aws_vpc.vpc.id
  name         = "sec_group_github_runner"
  description = "Security Group of Github Runner"
  tags = {
     Name = "GitHub_runner_SG"
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ec2_launch_template" {
  name        = "github_runner_launch_template"
  description = "Launch Template for GitHub Runners EC2 AutoScaling Group"

  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids  = ["${aws_security_group.security_group.id}"]

  user_data = base64encode(templatefile("${path.cwd}/bootstrap.tmpl", { github_repo_url = var.github_repo_url, github_repo_pat_token = var.github_repo_pat_token, runner_name = var.runner_name, labels = join(",", var.labels) }))

  tags = {
    Name = "github_runner"
  }
}

resource "aws_autoscaling_group" "github_runners_autoscaling_group" {
  name                      = "github_runners_autoscaling_group"
  vpc_zone_identifier       = var.subnets_private
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}
