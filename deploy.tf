# Terraform deployment file
# Separate variables definitions required

provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_autoscaling_group" "api-asg" {
  name = "${aws_launch_configuration.api-lc.name}"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.api-lc.name}"
  load_balancers = ["${var.api_elb}"]
  vpc_zone_identifier = ["${split(",", var.subnets)}"]
  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "val-asg" {
  name = "${aws_launch_configuration.val-lc.name}"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.val-lc.name}"
  load_balancers = ["${var.val_elb}"]
  vpc_zone_identifier = ["${split(",", var.subnets)}"]
  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "api-lc" {
  name = "${var.api_name_prefix}_${lookup(var.aws_amis, var.aws_region)}"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.api_iam_profile}"
  # Security group
  security_groups = ["${split(",", var.api_sec_groups)}"]
  user_data="${var.api_user_data}"
  key_name = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "val-lc" {
  name = "${var.val_name_prefix}_${lookup(var.aws_amis, var.aws_region)}"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.val_iam_profile}"
  # Security group
  security_groups = ["${split(",", var.val_sec_groups)}"]
  user_data="${var.val_user_data}"
  key_name = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}