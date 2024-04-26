# Example: Basic Ubuntu

## Features included

- Create a new security group with custom rules
- Define the AMI to use based on EC2 filters
- Associate two SSM documents for enabling automatic updates and joining to an AWS Directory Service domain
- Custom user-data script to change the hostname

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
