output "ami_id" {
  value = data.aws_ami.fetch_ami.id
}