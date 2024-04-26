locals {
  name = "amazon-linux"

  tags = {
    Creator = "admin"
    ENV     = "DEV"
  }
}

module "ec2_instance" {
  source = "../../"

  instance_type                = "t3a.small"
  key_name                     = "admin-key"
  name                         = local.name
  subnet_id                    = "subnet-aaabbbcccdddeeeff"
  associate_public_ip_address  = true
  create_custom_security_group = true

  security_group_rules = {
    out-all = {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all outgoing traffic"
      ipv6_cidr_blocks = ["::/0"]
      protocol         = -1
      type             = "egress"
    }

    in-ssh = {
      cidr_blocks = ["1.2.3.4/32"]
      description = "Allow incoming SSH traffic from trusted IPs"
      port        = 22
    }
  }
  # AMI defined by ID: Amazon Linux 2023 AMI 2023.4.20240416.0 x86_64 HVM kernel-6.1
  ami = "ami-04e5276ebb8451442"

  # Changes to the AMI ID changes should be ignored by Terraform
  ignore_ami_changes = true

  # AMI defined by SSM Parameter name
  # ami_ssm_parameter = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"

  # IMDSv2 enabled
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  user_data_scripts = {
    change-hostname = {
      filename = "change-hostname.sh"

      content = <<EOT
#!/bin/sh
hostnamectl set-hostname ${local.name}
EOT
    }

    update-packages = {
      filename = "update.sh"
      content  = file("update.sh")
    }
  }

  instance_tags = local.tags
  tags          = local.tags
}
