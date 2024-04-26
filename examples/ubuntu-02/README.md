# Example: Basic Ubuntu

## Features included

- Assign existing security groups
- Define the AMI to use from SSM ParameterStore
- Create an instance profile with specific policies attached

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
