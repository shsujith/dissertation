#Defining the resources, service and names
resource "aws_instance" "Payload_redirector" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.redirector.id]

  tags = {
    Name = "Payload Redirector"
  }

  #Remote execution
  provisioner "remote-exec" {
    inline = [
      "sudo su <<EOF",
      "echo \"@reboot root iptables -t nat -I PREROUTING -p tcp --dport 22 -jump ACCEPT\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -I INPUT -p tcp -m tcp --dport 80 -jump ACCEPT\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -t nat -A PREROUTING -p tcp --dport 80 -jump DNAT --to-destination ${aws_instance.payload_server.public_ip}\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -t nat -A POSTROUTING -j MASQUERADE\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -I FORWARD -jump ACCEPT\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -P FORWARD ACCEPT\" >> /etc/cron.d/firewall",
      "echo \"@reboot root iptables -A OUTPUT -p tcp -jump ACCEPT\" >> /etc/cron.d/firewall",
      "echo \"@reboot root sysctl net.ipv4.ip_forward=1\" >> /etc/cron.d/firewall",
      "shutdown -r",
    ]
  }

  #Connection block
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${abspath(path.cwd)}/aws_key")
    timeout     = "4m"
  }
}