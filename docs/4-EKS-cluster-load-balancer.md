# Setup EKS cluster with load balancer

- <https://cto.ai/blog/aws-load-balancer-controller-on-eks-cluster/>

## Create EKS cluster

```bash
eksctl create cluster \
  --name my-cluster-1 \
  --region ap-southeast-1 \
  --nodegroup-name my-nodes \
  --node-type t2.micro \
  --nodes 2
```

## Enable Service Account IAM provider\

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster=my-cluster-1 \
  --region=ap-southeast-1  \
  --approve
```

## Create Cluster role

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
```

## Create AWS IAM Policy

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

## Create Service Account

```bash
eksctl create iamserviceaccount \
  --cluster=my-cluster-1 \
  --region=ap-southeast-1  \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::636981878437:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

## Deploy Certification Manager

```bash
kubectl apply \
  --validate=false \
  -f https://github.com/jetstack/cert-manager/releases/download/v1.1.1/cert-manager.yaml
```

## Install the Ingress Controller

```bash
curl -Lo v2_4_4_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.4/v2_4_4_full.yaml

## **Update cluster name in line 731 of v2_4_4_full.yaml file**

kubectl apply -f v2_4_4_full.yaml
```

## Deploy the Deployment and Service Configurations

```bash
cat > deploy.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
        - name: nginx-deployment
          image: nginx
          ports:
          - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx-deployment
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30000
EOF

kubectl apply -f deploy.yaml
```

## Deploy Ingress Configurations

```bash
cat > ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: nginx-ingress
 annotations:
   kubernetes.io/ingress.class: alb
   alb.ingress.kubernetes.io/scheme: internet-facing
   alb.ingress.kubernetes.io/target-type: instance
  #  alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:636981878437:certificate/<cert value>
   alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
   alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
 rules:
   - host: example.com
     http:
       paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: nginx-service
               port:
                 number: 80
EOF

kubectl apply -f ingress.yaml
```

```bash
cat > ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    # kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx-service
              port:
                number: 80
EOF

kubectl apply -f ingress.yaml
```

## Error

```text
Error from server (InternalError): error when creating "ingress.yaml": Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
```
