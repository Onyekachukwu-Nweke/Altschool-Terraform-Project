
data "aws_instances" "ec2_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.ec2-asg.name]
  }
}

resource "aws_launch_template" "ec2-launch_temp" {
  name          = "ec2-launch_temp"
  image_id      = var.server_info.image_id
  instance_type = var.server_info.instance_type
  key_name      = var.server_info.key_name

  tags = {
    Name = "ec2-launch_temp"
  }
}

resource "aws_autoscaling_group" "ec2-asg" {
  name            = "ec2-asg"
  desired_capacity = 3
  min_size = 3
  max_size = 3
  vpc_zone_identifier = [for subnet in aws_subnet.az : subnet.id]
  target_group_arns = [aws_alb_target_group.tg.arn]
  # security_groups    = [aws_security_group.altschool_sg.id, aws_security_group.elb-sg.id]

  launch_template {
    id      = aws_launch_template.ec2-launch_temp.id
    version = "$Latest"
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "ec2-${1}"
    propagate_at_launch = true
  }
}

data "template_file" "inventory_file" {
  template = "{{ range $i, $instance := .Instances -}}{{ $instance.PublicIP }} ansible_host={{ $instance.PublicIP }} ansible_user=ubuntu\n{{- end }}"

  vars = {
    Instances = [for instance in data.aws_instances.ec2_instances: instance.public_ip if instance.public_ip != null]
  }
}

resource "null_resource" "write_inventory_file" {
  provisioner "local-exec" {
    command = "echo -e ${data.template_file.inventory_file.rendered} >> ./ansible/inventory && ansible-playbook -i ./ansible/inventory --private-key ${var.private_key_path} /ansible/site.yml"
  }
}

