#Block 1 Defining the resource, service provisioned and the name of the server.
resource "aws_instance" "c2_server" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main_servers-sg.id]

  tags = {
    Name = "C2 Main Server"
  }
  #Block 2 - Remote execution
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install curl",
      "sudo mkdir -p /home/ubuntu/metasploit_framework",
      "cd /home/ubuntu/metasploit_framework",
      "sudo bash -c \"curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall\" ",
      "sudo chmod 755 msfinstall",
      "sudo ./msfinstall",
      "sudo su <<EOF",
      "echo \"@reboot root cd /home/ubuntu/metasploit_framework; $ ./msfconsole\" >> /etc/cron.d/mdadm",
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