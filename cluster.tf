provider "aws" {
  region     = "eu-central-1"
}

resource "aws_ecs_cluster" "playground" {
  name = "playground"
}

data "ignition_systemd_unit" "ecs_agent" {
  name = "ecs-agent.service"
  content = "${file("templates/cluster/systemd/units/ecs_agent.tpl")}"
}

data "template_file" "ecs_config" {
  template = "${file("templates/cluster/systemd/files/ecs_agent_config.tpl")}"
  vars = {
    cluster_name = "${aws_ecs_cluster.playground.name}"
  }
}

data "ignition_file" "ecs_config" {
  filesystem = "root"
  path = "/etc/ecs/ecs.config"
  content {
    content = "${data.template_file.ecs_config.rendered}"
  }
}

data "ignition_config" "cluster_ignition" {
  systemd = [
    "${data.ignition_systemd_unit.ecs_agent.id}",
  ]
  files = [
    "${data.ignition_file.ecs_config.id}",
  ]
}

data "template_file" "cfn_stack" {
  template = "${file("templates/cluster/cfn_stack.yaml.tpl")}"
  vars = {
    user_data = "${data.ignition_config.cluster_ignition.rendered}"
  }
}

resource "aws_cloudformation_stack" "cluster_stack" {
  name = "cluster"
  template_body = "${data.template_file.cfn_stack.rendered}"
  capabilities = ["CAPABILITY_IAM"]
}