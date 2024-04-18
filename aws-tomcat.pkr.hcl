packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "tomcat-aws-ubuntu-java"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu_java" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu_java"
  ]

  provisioner "shell" {

    inline = [
      "echo Install - START",
      "sleep 10",
      "sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat",
      "sudo apt-get update",
      "sudo apt-get install -y default–jdk",
      "java -version",
      "cd /tmp",
      "wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.20/bin/apache-tomcat-10.0.20.tar.gz",
      "sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1",
      "sudo chown -R tomcat:tomcat /opt/tomcat/",
      "sudo chmod -R u+x /opt/tomcat/bin",
      "cat /opt/tomcat/webapps/manager/META-INF/context.xml",
      "sudo update-java-alternatives -l",
      "sudo -u tomcat /opt/tomcat/bin/startup.sh",
      "echo Install - SUCCESS",
    ]
  }
}
