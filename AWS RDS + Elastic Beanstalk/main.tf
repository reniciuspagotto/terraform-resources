provider "aws" {
  version = "~> 2.8"
  region = "sa-east-1"
  access_key = "******"
  secret_key = "******"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-name"
    key    = "terraform.tfstate"
    region = "sa-east-1"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "name-subnet-group"
  subnet_ids = ["subnet-00e760e115bcb04b3", "subnet-03371a6924acef2ab", "subnet-086e990193a8708f2"]
}

resource "aws_security_group" "main" {
  name = "name-sg"

  description = "RDS database servers (terraform-managed)"
  vpc_id = "vpc-09faea232134dc4f4"

  ingress {
    from_port = 1433
    to_port = 1433
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  allocated_storage        = 20
  db_subnet_group_name     = aws_db_subnet_group.main.name
  engine                   = "sqlserver-ex"
  identifier               = "nameofyouridentifier"
  instance_class           = "db.t2.micro"
  username                 = "youruser"
  password                 = "yourpassword"
  port                     = 1433
  publicly_accessible      = true
  storage_type             = "gp2"
  vpc_security_group_ids   = ["${aws_security_group.main.id}"]
}

resource "aws_elastic_beanstalk_application" "main" {
  name        = "online-consulting-plataform-api"
  description = "Online Consulting is a Plataform"
}

resource "aws_elastic_beanstalk_environment" "main" {
  name                = "online-consulting-plataform-api-env"
  application         = aws_elastic_beanstalk_application.main.name
  solution_stack_name = "64bit Windows Server Core 2019 v2.5.6 running IIS 10.0"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "vpc-09faea232134dc4f4"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "subnet-00e760e115bcb04b3,subnet-03371a6924acef2ab,subnet-086e990193a8708f2"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ConnectionStrings__OnlineConsultingDatabase"
    value = "Server=${aws_db_instance.main.address},${aws_db_instance.main.port};Initial Catalog=OnlineConsulting;Persist Security Info=False;User ID=${aws_db_instance.main.username};Password=${aws_db_instance.main.password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}