# Functions

## List Functions

```bash
region=ap-southeast-1
aws lambda list-functions --region $region
```

## Delete Functions

```bash
region=ap-southeast-1
functions=(`aws lambda list-functions --query 'Functions[].<FunctionName>'  --region $region --output text`)
for func in "${functions[@]}"; do
  echo "Deleting $func function"
  aws lambda delete-function --region $region --function-name "$func"
done
```
