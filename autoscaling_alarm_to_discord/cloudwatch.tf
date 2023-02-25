resource "aws_cloudwatch_metric_alarm" "sacle_up" {
  alarm_name          = "terraform-scale-up-alerm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asg-scale-out-policy.arn, aws_sns_topic.cloudwatch-alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "sacle_in" {
  alarm_name          = "terraform-scale-in-alerm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asg-scale-in-policy.arn, aws_sns_topic.cloudwatch-alarm.arn]
}
