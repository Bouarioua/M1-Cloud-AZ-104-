# 🌐 TP Azure avec Terraform — Compte-rendu & Proofs

##  TP1 — VM, SSH & NSG

### 1. Génération de la paire de clés SSH

```bash
ssh-keygen -t ed25519 -f ~/.ssh/cloud_tp1 -C "azure"
```

---

### 2. Ajout de la clé dans l’agent SSH

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cloud_tp1
ssh-add -l
```

---

### 3. Connexion SSH à la VM

```bash
ssh -i ~/.ssh/cloud_tp1 <admin>@<IP_PUBLIQUE>
```

**Preuves attendues :**

- Capture montrant le shell Ubuntu de la VM.

---

### 4. Vérification des services Azure

```bash
systemctl status walinuxagent
systemctl status cloud-init
```

**Preuves attendues :**

- `walinuxagent` actif
- `cloud-init` actif ou exited

---

### 5. Vérification des règles NSG effectives

```bash
NIC_ID=$(az vm show -g <RG> -n <VM> --query "networkProfile.networkInterfaces[0].id" -o tsv)
NIC_NAME=$(basename "$NIC_ID")

az network nic list-effective-nsg -g <RG> -n $NIC_NAME -o table
```

**Preuves attendues :**

- Table affichant la règle `allow-ssh` (Inbound / TCP / 22 / Source = ton IP/32)

---

## TP2 Partie 2 — DNS

### 1. Ajout d’un label DNS

- Ajout dans `azurerm_public_ip` :
  ```hcl
  domain_name_label = var.dns_label
  ```

**Preuves attendues :**

- Sortie `terraform apply` affichant le FQDN
- Vérification :
  ```bash
  az network public-ip show -g <RG> -n vm-ip --query "{ip: ipAddress, fqdn: dnsSettings.fqdn}" -o table
  ```

---

### 2. Connexion SSH via FQDN

```bash
ssh -i ~/.ssh/cloud_tp1 <admin>@<dns-label>.francecentral.cloudapp.azure.com
```

**Preuves attendues :**

- Connexion réussie via le FQDN

---

## TP2 Partie 3 — Blob Storage

### 1. Création Storage Account + Container

- Terraform : `azurerm_storage_account` + `azurerm_storage_container`

**Preuves attendues :**

- Sortie `terraform apply` OK

---

### 2. Test avec AzCopy depuis la VM

```bash
azcopy login --identity
echo "hello from $(hostname) $(date)" > /tmp/hello.txt
azcopy copy /tmp/hello.txt "https://<SA>.blob.core.windows.net/<CN>/hello.txt"
azcopy list "https://<SA>.blob.core.windows.net/<CN>"
azcopy copy "https://<SA>.blob.core.windows.net/<CN>/hello.txt" /tmp/hello-down.txt
cat /tmp/hello-down.txt
```

**Preuves attendues :**

- AzCopy login réussi
- Listing du fichier dans le container
- Contenu du fichier affiché

---

### 3. Authentification manuelle (IMDS)

```bash
curl -s -H "Metadata:true"   "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/" | jq .
```

**Preuves attendues :**

- JSON contenant un `access_token`

---

## TP2 Partie 4 — Monitoring (CPU + RAM)

### 1. Déploiement des alertes

- Terraform :
  - `azurerm_monitor_action_group`
  - `azurerm_monitor_metric_alert` (CPU > 70%)
  - `azurerm_monitor_metric_alert` (RAM < 512MiB)

**Preuves attendues :**

- Sortie `terraform apply` OK

---

### 2. Lister les alertes

```bash
az monitor metric alert list -g <RG> -o table
```

**Preuves attendues :**

- Les 2 alertes CPU et RAM listées

---

### 3. Déclenchement des alertes avec stress-ng

Dans la VM :

```bash
sudo apt install -y stress-ng
stress-ng --cpu 4 --timeout 600s
stress-ng --vm 2 --vm-bytes 512M --timeout 600s
```

**Preuves attendues :**

- Graphes CPU/RAM montants
- Emails d’alerte
- Commande :
  ```bash
  az monitor activity-log list --resource-group <RG> --max-events 20 -o table
  ```
  montrant les alertes fired

---

## TP2 Partie 5 — Azure Key Vault

### 1. Déploiement d’une Key Vault + secret

- Terraform :
  - `azurerm_key_vault`
  - `random_password`
  - `azurerm_key_vault_secret`

**Preuves attendues :**

- Sortie `terraform apply` OK

---
