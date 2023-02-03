
resource "aws_launch_template" "ec2-launch_temp" {
  name          = "ec2-launch_temp"
  image_id      = var.server_info.image_id
  instance_type = var.server_info.instance_type
  key_name      = var.server_info.key_name
}

resource "aws_autoscaling_group" "ec2-asg" {
  name            = "ec2-asg"
  desired_capacity = 3
  min_size = 3
  max_size = 5

  launch_template {
    id      = aws_launch_template.ec2-launch_temp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "altschool-tf-asg"
    propagate_at_launch = true
  }
}


resource "null_resource" "provision_instance" {
  count = length(var.public_subnet_cidrs)

  #depends_on = [
  # aws_instance.new_instance,
  #]
  provisioner "remote-exec" {
    inline = [
      "echo 'ssh connected'"
    ]
    connection {
      type        = "ssh"
      host        = aws_instance.new_instance[count.index].public_ip
      user        = "ubuntu"
      private_key = file("~/terraform-assignment/ass-key.cer")
    }
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.new_instance[count.index].public_ip} >> inventory && ansible-playbook -i inventory --private-key ${var.private_key_path} site.yml"


    #"ansible-playbook -i ${aws_instance.new_instance[count.index].public_ip}, --private-key ${var.private_key_path} site.yml"

    #"echo ${aws_instance.new_instance[count.index].public_ip} >> inventory && ansible-playbook -i #inventory site.yml"
    #only    = var.provision_instance == true
  }
}