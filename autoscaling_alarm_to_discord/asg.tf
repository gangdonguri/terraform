# Launch_template
resource "aws_launch_template" "launch-template" {
  name                                 = "terraform-sprint-monitoring-template"
  image_id                             = "ami-0e735aba742568824"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.nano"
  key_name                             = "myKey"
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = ["sg-0e20ac15ac7dc08f9"]
  user_data              = filebase64("${path.module}/bootstrap.sh")
}

# Autoscaling Group
resource "aws_autoscaling_group" "asg" {
  name               = "terraform-sprint-monitoring-ASG"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "asg-scale-out-policy" {
  name                   = "Scaling Out"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 20
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 20
  }

}

resource "aws_autoscaling_policy" "asg-scale-in-policy" {
  name                   = "Scaling In"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  step_adjustment {
    scaling_adjustment          = -2
    metric_interval_upper_bound = -20
  }

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = -20
    metric_interval_upper_bound = 0
  }

}
