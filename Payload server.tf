#Block 1 Defining the resource, service provisioned and the name of the server.
resource "aws_instance" "payload_server" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main_servers-sg.id]

  tags = {
    Name = "Payload Main Server"
  }
}