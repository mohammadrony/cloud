# RDS Instances

```bash
aws rds describe-db-instances
```

Get instance details

```bash
aws rds describe-db-instances | jq -r '.DBInstances[] | {  
  "Host": .Endpoint.Address,
  "Port": .Endpoint.Port,
  "Username": .MasterUsername,
  "DBName": .DBName,
  "MultiAZ": .MultiAZ,
  "Availability Zone": .AvailabilityZone,
  "SecondaryAvailabilityZone": .SecondaryAvailabilityZone
}'
```
