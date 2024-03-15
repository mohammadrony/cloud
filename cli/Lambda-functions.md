# Commands for Lambda functions

## List Regions

```bash
aws ec2 describe-regions --region us-east-1 --output text | cut -f4
```

## List Functions in all region

```bash
for region in `aws ec2 describe-regions --region us-east-1 --output text | cut -f4`; do
  aws lambda list-functions --region $region --output text
done
```

## Delete Functions

```bash
region=us-east-1
functions=(`aws lambda list-functions --query 'Functions[].<FunctionName>'  --region $region --output text`)
for func in "${functions[@]}"; do
  echo "Deleting $func function"
  aws lambda delete-function --region $region --function-name "$func"
done
```
