# Restore Snapshot

Restore Database

- Goto [RDS Dashboard](https://console.aws.amazon.com/rds/home) > Selct Region
- DB Instances > Select Database > Maintenance & backups
- Snapshots > Select snapshot > Actions > Restore snapshot
- Availability > Select Deployment options > Enter new DB instance identifier
- Insance configuration > Burstable / Standard / Memory optimized classes > Select instance
- Enter Storage type > Enter Allocated storage (Min: 20GiB) > Advanced settings
- Connectivity > Select VPC > Select subnet group > Public access (yes/no) > VPC security group
- Password authentication > Enable deletion protection > Restore DB instance.

Copy snapshot

- Goto [RDS Dashboard](https://console.aws.amazon.com/rds/home) > Selct Region
- DB Instances > Select Database > Maintenance & backups
- Snapshots > Select snapshot > Actions > Copy snapshot
- Enter New DB snapshot identifier > Select Destination Region > Copy tags
- Copy snapshot.
