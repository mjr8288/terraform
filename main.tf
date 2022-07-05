resource "aws_security_group" "dynamic-sg1" {
  name="Allow-Custom-Traffic"

  dynamic "ingress"{
    for_each=var.sg_ports
    iterator=port
    content{
      from_port=port.value
      to_port=port.value
      protocol="tcp"
      cidr_blocks=["0.0.0.0/0"]
    }
  }
  egress {
    from_port=0
    to_port=65535
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
    ipv6_cidr_blocks=["::/0"]
  }
  egress {
    from_port=0
    to_port=65535
    protocol="udp"
    cidr_blocks=["0.0.0.0/0"]
    ipv6_cidr_blocks=["::/0"]
  }
  tags=local.common_tags
}

resource "aws_instance" "myec2" {
  ami="ami-052efd3df9dad4825"
  instance_type="t2.micro"
  key_name="login-key1"
  security_groups=["Allow-Custom-Traffic"]
  tags=local.common_tags
  depends_on=[aws_security_group.dynamic-sg1]

  provisioner "remote-exec" {
    inline=[
      "sudo apt update",
      "sudo apt-get update",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
connection {
  type="ssh"
  host=self.public_ip
  user="ubuntu"
  private_key="${file("./login-key1.pem")}"
}
provisioner "local-exec" {
  command="echo ${aws_instance.myec2.public_ip} >> public-ip.txt"
}

}
