# GCP CLI Installation

[Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)

```bash
sudo apt install -y apt-transport-https ca-certificates gnupg curl
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```

```bash
sudo apt update
sudo apt install -y google-cloud-cli
```

Commands

```bash
gcloud
```
