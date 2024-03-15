# Configure new IAM profile

## Save user credentials in files

Update user credentials

```bash
vi ~/.aws/credentials
```

```credentials
[profile <new-role>]
aws_access_key_id = <access-key-id>
aws_secret_access_key = <secret-access-key>
```

Update user config

```bash
vi ~/.aws/config
```

```config
[profile <new-role>]
region = <region>
output = json
```

## Using new profile in commands

Using parameter in command

```bash
aws <commands> --profile <new-role>
```

Set Profile for current terminal session

```bash
export AWS_PROFILE=<new-role>
```

```bash
echo "export AWS_PROFILE=<new-role>" >> ~/.bashrc
```
