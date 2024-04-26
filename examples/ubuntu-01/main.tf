locals {
  tags = {
    Creator = "admin"
    ENV     = "DEV"
  }
}

module "ec2_instance" {
  source = "../../"

  instance_type = "t3a.small"
  key_name      = "admin-key"
  name          = "ubuntu-01"
  subnet_id     = "subnet-aaabbbcccdddeeeff"

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
      cidr_blocks = ["172.16.0.0/12", "10.0.0.0/8"]
      description = "Allow incoming SSH traffic from trusted IPs"
      port        = 22
    }
  }

  # AMI defined by using a filter by name and arch
  ami_filters = {
    enabled = true

    filter = {
      by_name = {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      }

      by_arch = {
        name   = "architecture"
        values = ["x86_64"]
      }
    }
  }

  root_block_device = [
    {
      encrypted   = true
      volume_size = 30
      volume_type = "gp3"
      # kms_key_id = "arn:aws:kms:us-east-1:636700535426:key/070696b7-0aee-4a85-bc26-8f4680204893"
    }
  ]

  ebs_block_devices = {
    data_01 = {
      device_name = "/dev/sdf"
      encrypted   = true
      volume_size = 50
      type        = "gp3"
      # kms_key_id = "arn:aws:kms:us-east-1:636700535426:key/070696b7-0aee-4a85-bc26-8f4680204893"

      # Options that might be used when trying to detach an EBS volume
      # from an EC2 instance
      #
      # force_detach                   = true
      # skip_destroy                   = true
      # stop_instance_before_detaching = true
    }
  }

  instance_tags = local.tags
  tags          = local.tags
}
