# RDS Pricing

```bash
aws pricing get-products --service-code AmazonRDS --region=us-east-1
```

All instance for Singapore region

```bash
aws pricing get-products --service-code AmazonRDS --region us-east-1 --filters \
  "Type=TERM_MATCH,Field=location,Value=Asia Pacific (Singapore)" \
  | jq -rc '.PriceList[]' | jq -r '[
    .product.attributes.servicecode,
    .product.attributes.location,
    .product.attributes.instanceType,
    .product.attributes.usagetype,
    .product.attributes.memory,
    .product.attributes.vcpu,
    .product.attributes.physicalProcessor,
    .product.attributes.processorArchitecture,
    .product.attributes.currentGeneration,
    .terms.OnDemand[].priceDimensions[].unit,
    .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
    .terms.OnDemand[].priceDimensions[].description] | @csv' > rds-singapore_all.csv
```

Single instance for Singapore region

```bash
INSTANCE_TYPE=db.m1.small
aws pricing get-products --service-code AmazonRDS --region us-east-1 --filters \
  "Type=TERM_MATCH,Field=instanceType,Value=${INSTANCE_TYPE}" \
  "Type=TERM_MATCH,Field=location,Value=Asia Pacific (Singapore)" \
  | jq -rc '.PriceList[]' | jq -r '[
    .product.attributes.servicecode,
    .product.attributes.location,
    .product.attributes.instanceType,
    .product.attributes.usagetype,
    .product.attributes.memory,
    .product.attributes.vcpu,
    .product.attributes.physicalProcessor,
    .product.attributes.processorArchitecture,
    .product.attributes.currentGeneration,
    .terms.OnDemand[].priceDimensions[].unit,
    .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
    .terms.OnDemand[].priceDimensions[].description] | @csv' > rds-singapore_${INSTANCE_TYPE}.csv
```
