output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

output "PUBLIC-IP" {
  value = aws_instance.my-ec2.public_ip
}

output "PRIVATE-IP" {
  value = aws_instance.my-ec2.private_ip
}