# Reboot

[Rebooting a DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RebootInstance.html)

Get db identifier

```bash
aws rds describe-db-instances | jq -r '.DBInstances[] | {
  "dbidentifier": .DBInstanceIdentifier
}'
```

Simple reboot

```bash
aws rds reboot-db-instance \
    --db-instance-identifier dbidentifier
```

Reboot with failover

```bash
aws rds reboot-db-instance \
    --db-instance-identifier dbidentifier \
    --force-failover
```
