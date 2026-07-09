resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[var.subnet_index]
  vpc_security_group_ids = [aws_security_group.web.id]

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  tags = {
    Name = "${var.name_prefix}-${terraform.workspace}-instance"
  }
}
