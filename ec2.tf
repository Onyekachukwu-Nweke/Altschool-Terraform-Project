
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
  
  launch_template {
    id      = aws_launch_template.ec2-launch_temp.id
    version = "$Latest"
  }

   lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "ec2-instance"
    propagate_at_launch = true
  }
}

locals {
  instances = flatten([for instance in data.aws_instances.ec2_instances : instance if instance != null])
}

data "template_file" "inventory_file" {
  template = "${templatefile("inventory.tpl", { Instances = jsonencode(local.instances) } )}"
  depends_on = [data.aws_instances.ec2_instances]
}

resource "null_resource" "write_inventory_file" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.inventory_file.rendered} >> ./ansible/inventory.txt && ansible-playbook -i ./ansible/inventory.txt --private-key ${var.private_key_path} ./ansible/site.yml"
  }

  depends_on = [data.aws_instances.ec2_instances]
}


output "inventory" {
  value = "${local.instances}"
}