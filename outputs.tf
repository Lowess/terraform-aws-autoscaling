output "alb_endpoint" {
  value = "${aws_lb.alb.dns_name}"
}

# output "alb_instances" {
#   value = ["${aws_instance.api.*.public_dns}"]
# }
