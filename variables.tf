## --------------------------------------------------------
## Custom variables
## --------------------------------------------------------
variable "create_custom_security_group" {
  description = "Whether to create a security group with custom rules or not."
  type        = bool
  default     = false
}

variable "custom_security_group_name" {
  description = "Name of the custom security group for the EC2 instance."
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = "Map of Security Group rules"
  type        = any # In fact, it's an object with attributes described below

  # --------------------------------
  # Descriptions
  # --------------------------------
  # type                     : (Optional) Type of rule. Either ingress or egress. Defaults to
  #                            ingress.
  #
  # port                     : (Optional) Port number. If defined, overrides both from_port and
  #                            to_port.
  #
  # from_port                : (Optional) Start port number
  #
  # to_port                  : (Optional) End port number
  #
  # port                     : (Optional) Port number. Used only if to_port and from_port are omitted.
  #
  # protocol                 : (Optional) Protocol. Defaults to TCP. Use -1 for all protocols
  #
  # description              : (Optional) Description of the rule
  #
  # prefix_list_ids          : (Optional) List of one of more prefix list IDs. Defaults to null.
  #
  # cidr_blocks              : (Optional: 1st priority) List of CIDR blocks. Can coexist with
  #                            ipv6_cidr_blocks. Defaults to null.
  #
  # ipv6_cidr_blocks         : (Optional: 1st priority) List of CIDR blocks. Can coexist with
  #                            cidr_blocks. Defaults to null.
  #
  # source_security_group_id : (Optional: 2nd priority) Source security group ID. Only used with
  #

  default = {}
}

variable "ssm_documents" {
  description = "Map of SSM documents and their parameters to execute on the instance"
  type        = any # In fact, it's an object with attributes described below

  #############################################################################
  # Descriptions
  #############################################################################
  #
  # document_format  : (Optional) The format of the document. Valid values are:
  #                    JSON, TEXT, YAML. Defaults to JSON.
  #
  # document_version : (Optional) The document version you want to associate
  #                    with the target(s). Can be a specific version or the
  #                    default version. Defaults to null.
  #
  # parameters       : (Optional) A block of arbitrary string parameters to
  #                    pass to the SSM document.

  default = {}
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach to the instance"
  type        = any # In fact, it's an object with attributes described below

  #############################################################################
  # Descriptions
  #############################################################################
  #
  # availability_zone    : (Required) The AZ where the EBS volume will exist.
  #
  # encrypted            : (Optional) If true, the disk will be encrypted.
  #                        Defaults to true.
  #
  # final_snapshot       : (Optional) If true, snapshot will be created before
  #                        volume deletion. Defaults to false.
  #
  # iops                 : (Optional) The amount of IOPS to provision for the
  #                        disk. Only valid for type of io1, io2 or gp3.
  #
  # kms_key_id           : (Optional) The ARN for the KMS encryption key. When
  #                        specifying kms_key_id, encrypted needs to be set to
  #                        true.
  #
  # multi_attach_enabled : (Optional) Specifies whether to enable Amazon EBS
  #                        Multi-Attach. Multi-Attach is supported on io1 and
  #                        io2 volumes. Defaults to false.
  #
  # size                 : (Optional) The size of the drive in GiBs.
  #
  # snapshot_id          : (Optional) A snapshot to base the EBS volume off of.
  #
  # throughput           : (Optional) The throughput that the volume supports,
  #                        in MiB/s. Only valid for type of gp3.
  #
  # type                 : (Optional) The type of EBS volume. Can be standard,
  #                        gp2, gp3, io1, io2, sc1 or st1. Defaults to gp3.
  #
  # force_detach         : (Optional) Set to true if you want to force the
  #                        volume to detach. Useful if previous attempts failed
  #                        but use this option only as a last resort, as this
  #                        can result in data loss. Defaults to null.
  #
  # skip_destroy         : (Optional) Set this to true if you do not wish to
  #                        detach the volume from the instance to which it is
  #                        attached at destroy time, and instead just remove
  #                        the attachment from Terraform state. This is useful
  #                        when destroying an instance which has volumes
  #                        created by some other means attached. Defaults to
  #                        null.
  #
  # stop_instance_before_detaching : (Optional) Set this to true to ensure
  #                                  that the target instance is stopped before
  #                                  trying to detach the volume. Stops the
  #                                  instance, if it is not already stopped.
  #                                  Defaults to null.

  default = {}
}

variable "ami_filters" {
  description = "AMI filters"

  type = object({
    enabled = optional(bool, false)

    # (Optional) Limit search to userswith explicit launch permission on the
    # image. Valid items are the numeric account ID or self. Defaults to null.
    executable_users = optional(list(string), null)

    # (Optional) If true, all deprecated AMIs are included in the response. If
    # false, no deprecated AMIs are included in the response. If no value is
    # specified, the default value is false. Defaults to false.
    include_deprecated = optional(bool, false)

    # (Optional) If more than one result is returned, use the most recent AMI.
    # Defaults to true.
    most_recent = optional(bool, true)

    # (Optional) List of AMI owners to limit search. Valid values: an AWS
    # account ID, self (the current account), or an AWS owner alias (e.g.,
    # amazon, aws-marketplace, microsoft). Defaults to ["amazon"]
    owners = optional(list(string), ["amazon"])

    # (Optional) One or more name/value pairs to filter off of. There are 
    # several valid keys, for a full reference, check out this link:
    #
    # https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
    filter = optional(any, {})
  })

  default = {}
}

variable "user_data_scripts" {
  description = "Map of data sets which contain scripts to be used for provisioning the EC2 instance in the same way as the user_data field."
  type        = any # In fact, it's an object with attributes described below

  #############################################################################
  # Descriptions
  #############################################################################
  #
  # content      : (Required) Content of the script
  #
  # content_type : (Optional) Content-type. Defaults to text/x-shellscript
  #
  # filename     : (Optional) A filename to report in the header for the part.

  default = {}
}
## --------------------------------------------------------
## Default module variables
## --------------------------------------------------------
variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name for the AMI ID. For Amazon Linux AMI SSM parameters see [reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html)"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}

variable "ignore_ami_changes" {
  description = "Whether changes to the AMI ID changes should be ignored by Terraform. Note - changing this value will result in the replacement of the instance"
  type        = bool
  default     = false
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "maintenance_options" {
  description = "The maintenance options for the instance"
  type        = any
  default     = {}
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "capacity_reservation_specification" {
  description = "Describes an instance's Capacity Reservation targeting option"
  type        = any
  default     = {}
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = null
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "enclave_options_enabled" {
  description = "Whether Nitro Enclaves will be enabled on the instance. Defaults to `false`"
  type        = bool
  default     = null
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = list(map(string))
  default     = []
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it"
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = null
}

variable "host_id" {
  description = "ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "instance_tags" {
  description = "Additional tags for the instance"
  type        = map(string)
  default     = {}
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = null
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "launch_template" {
  description = "Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template"
  type        = map(string)
  default     = {}
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "optional"
  }
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = null
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}

variable "private_dns_name_options" {
  description = "Customize the private DNS name options of the instance"
  type        = map(string)
  default     = {}
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  type        = string
  default     = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block`"
  type        = list(string)
  default     = null
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs"
  type        = bool
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host"
  type        = string
  default     = null
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set"
  type        = bool
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  type        = map(string)
  default     = {}
}

variable "cpu_options" {
  description = "Defines CPU options to apply to the instance at launch time."
  type        = any
  default     = {}
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance" # This option is only supported on creation of instance type that support CPU Options https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html#cpu-options-supported-instances-values
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "Sets the number of CPU threads per core for an instance (has no effect unless cpu_core_count is also set)"
  type        = number
  default     = null
}

# Spot instance request
variable "create_spot_instance" {
  description = "Depicts if the instance is a spot instance"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "The maximum price to request on the spot market. Defaults to on-demand price"
  type        = string
  default     = null
}

variable "spot_wait_for_fulfillment" {
  description = "If set, Terraform will wait for the Spot Request to be fulfilled, and will throw an error if the timeout of 10m is reached"
  type        = bool
  default     = null
}

variable "spot_type" {
  description = "If set to one-time, after the instance is terminated, the spot request will be closed. Default `persistent`"
  type        = string
  default     = null
}

variable "spot_launch_group" {
  description = "A launch group is a group of spot instances that launch together and terminate together. If left empty instances are launched and terminated individually"
  type        = string
  default     = null
}

variable "spot_block_duration_minutes" {
  description = "The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360)"
  type        = number
  default     = null
}

variable "spot_instance_interruption_behavior" {
  description = "Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate`"
  type        = string
  default     = null
}

variable "spot_valid_until" {
  description = "The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable "spot_valid_from" {
  description = "The start date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection"
  type        = bool
  default     = null

}
variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}

################################################################################
# IAM Role / Instance Profile
################################################################################

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}
