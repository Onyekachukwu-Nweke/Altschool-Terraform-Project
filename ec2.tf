
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
