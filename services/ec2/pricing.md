# Pricing

```bash
aws pricing get-products --service-code AmazonEC2 --region=us-east-1
```

All instances

```bash
aws pricing get-products --service-code AmazonEC2 --region us-east-1 --filters \
  "Type=TERM_MATCH,Field=location,Value=Asia Pacific (Singapore)" \
  | jq -rc '.PriceList[]' | jq -r '[
    .product.attributes.servicecode,
    .product.attributes.location,
    .product.attributes.instanceType,
    .product.attributes.usagetype,
    .product.attributes.operatingSystem,
    .product.attributes.memory,
    .product.attributes.physicalProcessor,
    .product.attributes.processorArchitecture,
    .product.attributes.vcpu,
    .product.attributes.currentGeneration,
    .terms.OnDemand[].priceDimensions[].unit,
    .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
    .terms.OnDemand[].priceDimensions[].description] | @csv' > ec2-singapore_all.csv
```

Current generation instances

```bash
aws pricing get-products --service-code AmazonEC2 --region us-east-1 --filters \
 "Type=TERM_MATCH,Field=currentGeneration,Value=Yes" \
 "Type=TERM_MATCH,Field=location,Value=Asia Pacific (Singapore)" \
 | jq -rc '.PriceList[]' | jq -r '[
    .product.attributes.servicecode,
    .product.attributes.location,
    .product.attributes.instanceType,
    .product.attributes.usagetype,
    .product.attributes.operatingSystem,
    .product.attributes.memory,
    .product.attributes.physicalProcessor,
    .product.attributes.processorArchitecture,
    .product.attributes.vcpu,
    .product.attributes.currentGeneration,
    .terms.OnDemand[].priceDimensions[].unit,
    .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
    .terms.OnDemand[].priceDimensions[].description] | @csv' > ec2-singapore_current-gen.csv
```

On-demand instances

```bash
aws pricing get-products --service-code AmazonEC2 --region us-east-1 --filters \
 "Type=TERM_MATCH,Field=capacitystatus,Value=Used" \
 "Type=TERM_MATCH,Field=marketoption,Value=OnDemand" \
 "Type=TERM_MATCH,Field=currentGeneration,Value=Yes" \
 "Type=TERM_MATCH,Field=location,Value=Asia Pacific (Singapore)" \
 "Type=TERM_MATCH,Field=tenancy,Value=Shared" \
 "Type=TERM_MATCH,Field=operation,Value=RunInstances" \
 | jq -rc '.PriceList[]' | jq -r '[
    .product.attributes.servicecode,
    .product.attributes.location,
    .product.attributes.instanceType,
    .product.attributes.usagetype,
    .product.attributes.operatingSystem,
    .product.attributes.memory,
    .product.attributes.physicalProcessor,
    .product.attributes.processorArchitecture,
    .product.attributes.vcpu,
    .product.attributes.currentGeneration,
    .terms.OnDemand[].priceDimensions[].unit,
    .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
    .terms.OnDemand[].priceDimensions[].description] | @csv' > ec2-singapore_on-demand.csv
```
