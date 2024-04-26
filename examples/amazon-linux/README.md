# Example: Basic Ubuntu

## Features included

- Create a new security group with custom rules
- Define the AMI by an specific ID
- Enabled public IP
- Changes on the AMI are ignored: instance is not recreated
- IMDSv2 is set to required
- Two custom scripts are set on user-data

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
