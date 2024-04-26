# Example: Basic Ubuntu

## Features included

- Create a new security group with custom rules
- Define the AMI to use based on EC2 filters
- Root block device encrypted with an AWS managed KMS key and a custom size and type
- Extra EBS volume also encrypted with an AWS managed KMS key

## How to use it

1. If needed, update any values in main.tf
2. Init and run plan

```bash
terraform init
terraform plan
```

3. Apply changes:

```bash
terraform apply
```

4. Check instance ready and test whatever it's neeeded.

5. Destroy

```bash
terraform destroy
```
