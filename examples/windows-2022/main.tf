locals {
  name = "windows-2022"

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
      cidr_blocks = ["172.16.0.0/12", "192.168.0.0/16", "10.0.0.0/8"]
      description = "Allow incoming RDP traffic from trusted IPs"
      port        = 3389
    }
  }

  # SSM documents to associate to the EC2 instance
  # - Enable auto installation of Windows Updates
  # - Join to an AWS Directory Service domain (AD)
  ssm_documents = {
    AWS-ConfigureWindowsUpdate = {
      parameters = {
        updateLevel          = "InstallUpdatesAutomatically"
        scheduledInstallDay  = "Saturday"
        scheduledInstallTime = "22:00"
      }
    }

    AWS-JoinDirectoryServiceDomain = {
      parameters = {
        directoryId    = "d-0123456789"
        directoryName  = "contoso.net"
        dnsIpAddresses = "172.19.43.243"
      }
    }
  }

  # AMI defined by using a filter by name and arch
  ami_filters = {
    enabled = true

    filter = {
      by_name = {
        name   = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
      }

      by_device_type = {
        name   = "root-device-type"
        values = ["ebs"]
      }
    }
  }

  # AMI defined by SSM Parameter name
  # ami_ssm_parameter = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"

  user_data = <<EOT
<powershell>
$newHostname = "${local.name}"
Rename-Computer -NewName $newHostname -Force
</powershell>
EOT

  instance_tags = local.tags
  tags          = local.tags
}
