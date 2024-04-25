###############################################################################
# Network related settings of the EC2 instance
###############################################################################
data "aws_subnet" "selected" {
  count = var.create ? 1 : 0

  id = length(var.network_interface) > 0 ? data.aws_network_interface.selected[0].subnet_id : var.subnet_id
}

data "aws_network_interface" "selected" {
  count = var.create ? length(var.network_interface) : 0

  id = var.network_interface[count.index].network_interface_id
}

###############################################################################
# AMI selection for the EC2 instance and AMI properties
###############################################################################
locals {
  # Order of criteria for selecting the AMI:
  #
  # 1st: Use AMi filters with var.ami_filters
  #
  # 2nd: Use an specific AMI ID with var.ami
  #
  # 3rd: Last resort. Use AMI defined in the SSM ParameterStore with
  #      var.smi_ssm_parameter
  ami = coalesce(
    try(data.aws_ami.filtered[0].id, null),
    var.ami,
    try(data.aws_ssm_parameter.this[0].value, null)
  )
}

# 1st criteria: Select AMI based on filters
data "aws_ami" "filtered" {
  count = var.create && var.ami_filters.enabled ? 1 : 0

  executable_users   = var.ami_filters.executable_users
  include_deprecated = var.ami_filters.include_deprecated
  most_recent        = var.ami_filters.most_recent
  owners             = var.ami_filters.owners

  dynamic "filter" {
    for_each = var.ami_filters.filter

    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# 2nd criteria: Select AMI based on SSM ParameterStore
data "aws_ssm_parameter" "this" {
  count = var.create && var.ami_ssm_parameter != null ? 1 : 0

  name = var.ami_ssm_parameter
}

###############################################################################
# User-data for the EC2 instance
###############################################################################
data "cloudinit_config" "user_data" {
  count = var.create && length(var.user_data_scripts) > 0 ? 1 : 0

  gzip          = true
  base64_encode = true

  dynamic "part" {
    for_each = var.user_data_scripts

    content {
      content      = part.value.content
      content_type = try(part.value.content_type, "text/x-shellscript")
      filename     = try(part.value.filename, null)
    }
  }
}

###############################################################################
# Security Groups for the EC2 instance
###############################################################################
locals {
  vpc_security_group_ids = concat(try([module.security_group[0].id], []), var.vpc_security_group_ids)
}

module "security_group" {
  count = var.create && var.create_custom_security_group ? 1 : 0

  source = "git@github.com:sfinetworks/terraform-aws-simple-security-group.git?ref=1.1.0"

  name = (
    var.custom_security_group_name == null ?
    "sg_${var.name}" :
    var.custom_security_group_name
  )

  description            = "Security Group for the instance ${var.name}"
  use_random_name_suffix = var.custom_security_group_name == null
  rules                  = var.security_group_rules
  vpc_id                 = data.aws_subnet.selected[0].vpc_id

  tags = var.tags
}

###############################################################################
# Association with SSM documents
###############################################################################
data "aws_ssm_document" "selected" {
  for_each = var.ssm_documents

  name             = each.key
  document_format  = try(each.value.document_format, "JSON")
  document_version = try(each.value.document_version, null)
}

resource "aws_ssm_association" "this" {
  for_each = var.ssm_documents

  name       = data.aws_ssm_document.selected[each.key].name
  parameters = try(each.value.parameters, {})

  document_version = (
    length(regexall("^AWS-", data.aws_ssm_document.selected[each.key].name)) > 0 ?
    null :
    data.aws_ssm_document.selected[each.key].document_version
  )

  targets {
    key    = "InstanceIds"
    values = [module.ec2_instance.id]
  }
}

###############################################################################
# EBS devices created separately from the ec2_instance module
###############################################################################
resource "aws_ebs_volume" "this" {
  for_each = var.create ? var.ebs_block_devices : {}

  availability_zone    = try(each.value.availability_zone, data.aws_subnet.selected[0].availability_zone, null)
  encrypted            = try(each.value.encrypted, true)
  final_snapshot       = try(each.value.final_snapshot, false)
  iops                 = try(each.value.iops, null)
  kms_key_id           = try(each.value.kms_key_id, null)
  multi_attach_enabled = try(each.value.multi_attach_enabled, false)
  size                 = each.value.volume_size
  snapshot_id          = try(each.value.snapshot_id, null)
  throughput           = try(each.value.throughput, null)
  type                 = try(each.value.type, "gp3")

  tags = merge(
    var.tags,
    {
      Name = "${var.name}_${each.key}"
    }
  )
}

resource "aws_volume_attachment" "this" {
  for_each = var.create ? var.ebs_block_devices : {}

  device_name                    = each.value.device_name
  force_detach                   = try(each.value.force_detach, null)
  skip_destroy                   = try(each.value.skip_destroy, null)
  stop_instance_before_detaching = try(each.value.stop_instance_before_detaching, null)
  instance_id                    = module.ec2_instance.id
  volume_id                      = aws_ebs_volume.this[each.key].id
}

locals {
  # Force setting custom tags for the root block device
  root_block_device = [
    merge(
      var.root_block_device[0],
      {
        tags = merge(
          var.tags,
          {
            Name = "${var.name}_bootdisk"
          }
        )
      }
    )
  ]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  create                               = var.create
  name                                 = var.name
  ami_ssm_parameter                    = var.ami_ssm_parameter
  ami                                  = local.ami
  ignore_ami_changes                   = var.ignore_ami_changes
  associate_public_ip_address          = var.associate_public_ip_address
  maintenance_options                  = var.maintenance_options
  availability_zone                    = var.availability_zone
  capacity_reservation_specification   = var.capacity_reservation_specification
  cpu_credits                          = var.cpu_credits
  disable_api_termination              = var.disable_api_termination
  ebs_block_device                     = []
  ebs_optimized                        = var.ebs_optimized
  enclave_options_enabled              = var.enclave_options_enabled
  ephemeral_block_device               = var.ephemeral_block_device
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation
  host_id                              = var.host_id
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  ipv6_address_count                   = var.ipv6_address_count
  ipv6_addresses                       = var.ipv6_addresses
  key_name                             = var.key_name
  launch_template                      = var.launch_template
  metadata_options                     = var.metadata_options
  monitoring                           = var.monitoring
  network_interface                    = var.network_interface
  private_dns_name_options             = var.private_dns_name_options
  placement_group                      = var.placement_group
  private_ip                           = var.private_ip
  root_block_device                    = local.root_block_device
  secondary_private_ips                = var.secondary_private_ips
  source_dest_check                    = var.source_dest_check
  subnet_id                            = var.subnet_id
  tenancy                              = var.tenancy
  user_data                            = var.user_data
  user_data_base64                     = try(data.cloudinit_config.user_data[0].rendered, var.user_data_base64)
  user_data_replace_on_change          = var.user_data_replace_on_change
  volume_tags                          = {}
  enable_volume_tags                   = false
  vpc_security_group_ids               = local.vpc_security_group_ids
  timeouts                             = var.timeouts
  cpu_options                          = var.cpu_options
  cpu_core_count                       = var.cpu_core_count
  cpu_threads_per_core                 = var.cpu_threads_per_core
  create_spot_instance                 = var.create_spot_instance
  spot_price                           = var.spot_price
  spot_wait_for_fulfillment            = var.spot_wait_for_fulfillment
  spot_type                            = var.spot_type
  spot_launch_group                    = var.spot_launch_group
  spot_block_duration_minutes          = var.spot_block_duration_minutes
  spot_instance_interruption_behavior  = var.spot_instance_interruption_behavior
  spot_valid_until                     = var.spot_valid_until
  spot_valid_from                      = var.spot_valid_from
  disable_api_stop                     = var.disable_api_stop
  putin_khuylo                         = var.putin_khuylo
  create_iam_instance_profile          = var.create_iam_instance_profile
  iam_role_name                        = var.iam_role_name
  iam_role_use_name_prefix             = var.iam_role_use_name_prefix
  iam_role_path                        = var.iam_role_path
  iam_role_description                 = var.iam_role_description
  iam_role_permissions_boundary        = var.iam_role_permissions_boundary
  iam_role_policies                    = var.iam_role_policies

  instance_tags = var.instance_tags
  tags          = var.tags
  iam_role_tags = var.iam_role_tags
}
