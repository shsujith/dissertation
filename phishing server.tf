#Block 1 - Defining the resource, service provisioned and the name of the server.
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

}
resource "aws_instance" "phishing_server" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main_servers-sg.id]

  tags = {
    Name = "Phishing Main Server"
  }
  #Block 2 - Remote execution
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install zip",
      "sudo mkdir -p /home/ubuntu/gophish",
      "cd /home/ubuntu/gophish",
      "sudo wget https://github.com/gophish/gophish/releases/download/v0.12.0/gophish-v0.12.0-linux-64bit.zip",
      "sudo unzip gophish-v0.12.0-linux-64bit.zip",
      "cd  /home/ubuntu/gophish/gophish-v0.12.0-linux-64bit",
      "sudo sed -i 's/127.0.0.1:3333/0.0.0.0:3333/g' config.json",
      "sudo chmod 777 ./gophish",
      "sudo su <<EOF",
      "echo \"@reboot root cd /home/ubuntu/gophish/gophish-v0.12.0-linux-64bit; ./gophish\" >> /etc/cron.d/mdadm",
      "shutdown -r"
    ]
  }
  #Block 3 – Connection
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${abspath(path.cwd)}/aws_key")
    timeout     = "4m"
  }
}
#Block 4 – AWS Key
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+pZfG+qv4UNeJP1PDrVFk9E3apWA8RGAZaW8EWxvkdqpNYzz8hhpBqm9IDVUXBsDU2nnh1bf7z4ucv6lw3VzlFPguzJ81z45WjTBiSuqajFO0QsD7yqyR4jUv52GsRszhv1nfLCGh7LELPvHH5wVKJErf7+PhbSWqxD40JlF1XrEcLeafew1eONgnouETyrShYBxVJzgdOR20dU/IPYBwozdyAwfBn/YzFu0d19aEEGK6BjgKzNTquspRmrE9r4Q1uhlwZBeSrN/AAea7MbXVmq/DXkhMxiXHPU5FIJCMkJ3G38DbjQ6KiS4inwnA1CYh1ebjTkTuqKbxVGZy5Um5 sujith@LAPTOP-R2DCPIQC"
}