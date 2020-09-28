output "instance_ips" {
  value = ["${aws_instance.mongodb_one.*.public_ip}"]
}