resource "aws_alb" "new_alb" {
  name               = "new-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets = aws_subnet.az.*.id
}

resource "aws_alb_target_group" "tg" {
  name     = "AlbTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 3
    unhealthy_threshold = 2
  }

}

resource "aws_alb_listener" "new_listener" {
  load_balancer_arn = aws_alb.new_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.arn
  default_action {
    target_group_arn = aws_alb_target_group.tg.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "http_to_https" {
  load_balancer_arn = aws_alb.new_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.tg.arn
    type             = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


output "alb_dns_name" {
  value = aws_alb.new_alb.dns_name
}

output "alb_arn" {
  value = aws_alb.new_alb.arn
}

output "target_group_arn" {
  value = aws_alb_target_group.tg.arn
}

output "target_group_name" {
  value = aws_alb_target_group.tg.name
}