#----------------------------------------------------
#
# DevOps Take Home Challenge
#
# by Ihor Sakhno
#
#----------------------------------------------------

provider "aws" {
  access_key = var.key_access
  secret_key = var.key_secret
  region     = "eu-central-1"
}

resource "aws_security_group" "docker_serv" {
  name        = "Docker server SG"
  description = "Allow port 80"

  ingress {
    description = "Open port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Open port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Docker server SG"
    owner = "Ihor Sakhno"
  }
}



resource "aws_instance" "docker_serv" {
  ami                    = "ami-00a205cb8e06c3c4e"
  instance_type          = "t2.micro"
  availability_zone      = "eu-central-1a"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.docker_serv.id]
  #  user_data              = templatefile("userdata.tpl", {})

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("is-franfurkt-key.pem")}"
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./doc/"
    destination = "/tmp/"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install docker",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "cd /tmp/",
      "sudo cp ./nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl start nginx",
      "sudo docker build -t web .",
      "sudo docker run -p 8000:80 -d --name web web",
    ]
  }

  tags = {
    Name  = "Docker Server"
    owner = "Ihor Sakhno"
  }

}

resource "aws_elb" "docker_elb" {
  name               = "dockerelb"
  availability_zones = ["eu-central-1a"]
  security_groups    = [aws_security_group.docker_serv.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances                   = [aws_instance.docker_serv.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name  = "Docker Server ELB"
    owner = "Ihor Sakhno"
  }

}
