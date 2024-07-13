# Instance

## List Regions

```bash
aws ec2 describe-regions --region us-east-1 --output text | cut -f4
```

## List Instance details for all region

```bash
for region in `aws ec2 describe-regions --region us-east-1 --output text | cut -f4`; do
  echo -e "\nListing instances in region:'$region'..."
  aws ec2 describe-instances --region $region
done
```

## List Instance id and state for all region

```bash
for region in `aws ec2 describe-regions --region us-east-1 --output text | cut -f4`; do
  echo -e "\nListing instances state in region:'$region'..."
  aws ec2 describe-instances --region $region | \
  jq '.Reservations[].Instances[] | "EC2: \(.InstanceId): \(.State.Name)"'
done
```

## List Running Instances in table

```bash
region=us-east-1
aws ec2 describe-instances \
  --query 'Reservations[].Instances[*].{InstanceType: InstanceType, InstanceId: InstanceId, State: State.Name}' \
  --filters Name=instance-state-name,Values=running \
  --region $region --profile lab --output table
```
