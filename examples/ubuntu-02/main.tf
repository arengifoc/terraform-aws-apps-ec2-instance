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
  name          = "ubuntu-02"
  subnet_id     = "subnet-aaabbbcccdddeeeff"

  vpc_security_group_ids = [
    "sg-aaabbbcccdddeeeff",
    "sg-iiijjjkkklllmmmnn"
  ]

  # AMI defined by SSM Parameter name
  ami_ssm_parameter = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"

  create_iam_instance_profile = true

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # iam_instance_profile        = "EC2_S3Access_Role"

  instance_tags = local.tags
  tags          = local.tags
}
