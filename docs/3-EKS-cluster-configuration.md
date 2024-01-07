# Configure EKS cluster with eksctl

Documentation URL:

- <https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/>
- <https://www.linkedin.com/pulse/how-set-up-application-load-balancer-aws-eks-using-manhar-dangar/>
- <https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/>

## Create EKS cluster

```bash
region=ap-southeast-1
instance_type=t2.medium
cluster_name=eks-cluster-1

eksctl create cluster --instance-types=${instance_type} --name=${cluster_name} --region=${region} --nodes-min=2 --nodes-max=5
```

## Configure Helm chart

### Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Add Helm charts

```bash
helm repo add stable https://charts.helm.sh/stable
helm repo add incubator https://charts.helm.sh/incubator
helm repo add eks https://aws.github.io/eks-charts
```

## Create an IAM OIDC provider for the cluster

```bash
region=ap-southeast-1
cluster_name=eks-cluster-1

eksctl utils associate-iam-oidc-provider --cluster=${cluster_name} --region=${region} --approve
```

## Deploy AWS ALB Ingress controller

### Deploy the relevant RBAC roles and role bindings

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
```

### Create an IAM policy to allow the ALB Ingress controller to make AWS API calls

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
       --policy-name ALBIngressControllerIAMPolicy \
       --policy-document file://iam_policy.json
```

### Create a Kubernetes service account and an IAM role

```bash
region=ap-southeast-1
cluster_name=eks-cluster-1
PolicyARN=arn:aws:iam::636981878437:policy/ALBIngressControllerIAMPolicy # Created in last command

eksctl create iamserviceaccount \
       --cluster=${cluster_name} \
       --namespace=kube-system \
       --name=alb-ingress-controller \
       --attach-policy-arn=${PolicyARN} \
       --override-existing-serviceaccounts \
       --region=${region} \
       --approve
```

## Install cert-manager to inject the certificate configuration

```bash
VERSION=v1.12.4
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${VERSION}/cert-manager.yaml
```

## Install Ingress controller

```bash
VERSION_d=v2.6.0
VERSION_u=v2_6_0

curl -Lo ingress-controller.yaml "https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/${VERSION_d}/${VERSION_u}_full.yaml"

# Replace the cluster name at 863 line

kubectl apply -f ingress-controller.yaml
```

## Add Controller on Cluster via Helm

### Install the TargetGroupBinding CRDs

```bash
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
```

## Deploy the AWS ALB Ingress controller

### Using kubectl

```bash
cluster_name=eks-cluster-1
region=ap-southeast-1
vpc_id=vpc-0e38f396d0140a2f9

curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" \
     | sed "s/# - --cluster-name=devCluster/- --cluster-name=${cluster_name}/g" \
     | sed "s/# - --aws-region=us-west-1/- --aws-region=${region}/g" \
     | sed "s/# - --aws-vpc-id=vpc-xxxxxx/- --aws-vpc-id=${vpc_id}/g" \
     | kubectl apply -f -
```

### Install via Helm

```bash
cluster_name=eks-cluster-1
region=ap-southeast-1
vpc_id=vpc-0e38f396d0140a2f9

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
       -n kube-system \
       --set clusterName=${cluster_name} \
       --set serviceAccount.create=false \
       --set region=${region} \
       --set vpcId=${vpc_id} \
       --set serviceAccount.name=aws-load-balancer-controller
```

## Deploy Nginx application

### Create Nginx server deployment

```bash
cat >> deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  selector:
    matchLabels:
      run: nginx-app
  replicas: 1
  template:
    metadata:
      labels:
        run: nginx-app
    spec:
      containers:
      - name: nginx-app
        image: nginx
        ports:
        - containerPort: 80

EOF

kubectl create -f deployment.yaml
```

### Create application service

```bash
cat >> service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    run: nginx-app
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: nginx-app

EOF

kubectl create -f service.yaml
```

### Create application networking

```bash
cat >> ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx-svc
              port:
                number: 80

EOF

kubectl create -f ingress.yaml
```

## Delete EKS cluster

```bash
cluster_name=eks-cluster-1
region=ap-southeast-1

eksctl delete cluster ${cluster_name} --region ${region}
```

## Extra

### Verify that the deployment was successful and the controller started

```bash
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
```
