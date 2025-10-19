# Configure IAM Profile

## Update in Command

Configure Access key with default option

```bash
aws configure

# AWS Access Key ID: ACCESS_KEY_ID
# AWS Secret Access Key: SECRET_KEY
# Default region name: REGION
# Default output format: json
```

## Region and Format List

Region list

| Code              | Global Location | Region Name   |
|-------------------|-----------------|---------------|
| `us-east-1`       | US East         | N. Virginia   |
| `ap-southeast-1`  | Asia Pacific    | Singapore     |
| `ap-south-2`      | Asia Pacific    | Hyderabad     |

Format list

| Code    | Name  |
|---------|-------|
| `json`  | JSON  |
| `text`  | Text  |
| `table` | Table |

## Configuration files

Credential file

```bash
vi ~/.aws/credentials
```

```credentials
[profile ROLE]
aws_access_key_id = ACCESS_KEY_ID
aws_secret_access_key = SECRET_KEY
```

*Update `ROLE`, `ACCESS_KEY_ID` and `SECRET_KEY` with real value.*

Update user config

```bash
vi ~/.aws/config
```

```config
[profile ROLE]
region = REGION
output = FORMAT
```

*Update `ROLE`, `REGION` and `FORMAT` with real value.*

## Select Profile

Available profiles

```bash
aws configure list-profiles
```

Current profile

```bash
aws configure list
```

```bash
aws sts get-caller-identity
```

Set default profile

```bash
# Update in ~/.bashrc and ~/.zshrc file.
export AWS_DEFAULT_PROFILE=PROFILE_NAME
# export AWS_PROFILE=PROFILE_NAME
```

Set Profile in command

```bash
aws <commands> --profile PROFILE_NAME
```

*Update `PROFILE_NAME` with real value.*
