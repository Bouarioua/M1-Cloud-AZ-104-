🌞 Allumez les VMs et effectuez la conf élémentaire :

ping kvm1.one depuis frontend.one :
ping kvm1.one
```bash
PING kvm1.one (192.168.180.2) 56(84) bytes of data.
64 bytes from kvm1.one (192.168.180.2): icmp_seq=1 ttl=64 time=0.544 ms
64 bytes from kvm1.one (192.168.180.2): icmp_seq=2 ttl=64 time=0.527 ms
64 bytes from kvm1.one (192.168.180.2): icmp_seq=3 ttl=64 time=0.396 ms
64 bytes from kvm1.one (192.168.180.2): icmp_seq=4 ttl=64 time=0.829 ms

--- kvm1.one ping statistics ---
```
ping kvm2.one depuis frontend.one :
ping kvm2.one
```bash
PING kvm2.one (192.168.180.3) 56(84) bytes of data.
64 bytes from kvm2.one (192.168.180.3): icmp_seq=1 ttl=64 time=0.678 ms
64 bytes from kvm2.one (192.168.180.3): icmp_seq=2 ttl=64 time=0.627 ms

--- kvm2.one ping statistics ---
```
II.1. Setup Frontend
A. Database
🌞 Installer un serveur MySQL
**1-Télécharger le RPM du dépôt MySQL**
wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm

**2-Installer le dépôt localement**
 sudo rpm -ivh mysql80-community-release-el9-5.noarch.rpm

**3-dnf search mysql**

-> vous devriez voir un paquet mysql-community-server dispo :
dnf search mysql
```bash
 sudo dnf install mysql-community-server -y
[sudo] password for mohamed:
Last metadata expiration check: 0:25:07 ago on Tue Sep 16 14:10:35 2025.
Package mysql-community-server-8.0.43-1.el9.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
**4-Installer le serveur MySQL**
sudo dnf install mysql-community-server -y


🌞 Démarrer le serveur MySQL

démarrer le service mysqld
activer ce service au démarrage


**5-Démarrer et activer MySQL**
sudo systemctl enable --now mysqld

**6-Vérifier que MySQL fonctionne**
$ systemctl status mysqld
```bash
● mysqld.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; prese>
     Active: active (running) since Tue 2025-09-16 14:12:18 CEST; 25s ago
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html
    Process: 3128 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, st>
   Main PID: 3193 (mysqld)
     Status: "Server is operational"
      Tasks: 38 (limit: 23126)
     Memory: 449.7M
        CPU: 3.041s
     CGroup: /system.slice/mysqld.service
             └─3193 /usr/sbin/mysqld

Sep 16 14:12:12 kvm1.one systemd[1]: Starting MySQL Server...
Sep 16 14:12:18 kvm1.one systemd[1]: Started MySQL Server.
 ^X
```

🌞 Setup MySQL
MySQL génère un mot de passe root par défaut. Pour l’afficher:
```bash
 sudo grep 'temporary password' /var/log/mysqld.log
2025-09-16T12:12:14.448881Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: 4CHMd3(snEVl
```

Connexion à MySQL:
mysql -u root -p

execution de la commande :
-- Définir un mot de passe root fort (exemple)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'StrongRootPassw0rd!';

-- Créer l'utilisateur OpenNebula
CREATE USER 'oneadmin' IDENTIFIED BY 'StrongOneAdminPassw0rd!';

-- Créer la base de données OpenNebula
CREATE DATABASE opennebula;

-- Accorder les privilèges à oneadmin sur la base
GRANT ALL PRIVILEGES ON opennebula.* TO 'oneadmin';

-- Définir le niveau d'isolation requis
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;

définir un mot de passe fort pour root:
ALTER USER 'root'@'localhost' IDENTIFIED BY 'StrongRootPassw0rd!';

## Setup OpenNebula Repository (frontend.one)

1. Création du fichier de dépôt :
```bash
sudo nano /etc/yum.repos.d/opennebula.repo

Contenu du fichier :
[opennebula]
name=OpenNebula Community Edition
baseurl=https://downloads.opennebula.io/repo/6.10/RedHat/$releasever/$basearch
enabled=1
gpgkey=https://downloads.opennebula.io/repo/repo2.key
gpgcheck=1
repo_gpgcheck=1

Rafraîchissement du cache :

sudo dnf makecache -y

## Installation d’OpenNebula (frontend.one)

Après avoir ajouté le dépôt OpenNebula et rafraîchi le cache (`dnf makecache -y`),  
nous installons les paquets nécessaires :

```bash
sudo dnf install -y opennebula opennebula-sunstone opennebula-fireedge


## Services OpenNebula

Après avoir installé OpenNebula et ses modules, il faut activer et démarrer les services pour que le frontend soit opérationnel.

### Commandes utilisées :

```bash
# Recharger la configuration systemd
sudo systemctl daemon-reload

# Activer et démarrer les services OpenNebula
sudo systemctl enable --now opennebula
sudo systemctl enable --now opennebula-sunstone
sudo systemctl enable --now opennebula-fireedge

# Vérifier que les services sont actifs
systemctl status opennebula
systemctl status opennebula-sunstone
systemctl status opennebula-fireedge
```
🌞 Ouverture firewall

## Configuration système - Firewall

Pour permettre l’accès à la WebUI Sunstone, au SSH, au daemon OpenNebula, au monitoring et au NoVNC proxy, les ports suivants doivent être ouverts :

| Port   | Protocole | Raison                               |
|--------|-----------|--------------------------------------|
| 9869   | TCP       | WebUI (Sunstone)                     |
| 22     | TCP       | SSH                                   |
| 2633   | TCP       | Daemon oned et API XML RPC           |
| 4124   | TCP/UDP   | Monitoring                            |
| 29876  | TCP       | NoVNC proxy                           |

### Commandes
```bash
sudo firewall-cmd --permanent --add-port=9869/tcp
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=2633/tcp
sudo firewall-cmd --permanent --add-port=4124/tcp
sudo firewall-cmd --permanent --add-port=4124/udp
sudo firewall-cmd --permanent --add-port=29876/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

## II.2 Noeuds KVM - Configuration initiale

### 🌞 1-Ajouter le dépôt OpenNebula
Créer le fichier `/etc/yum.repos.d/opennebula.repo` :

```bash
sudo nano /etc/yum.repos.d/opennebula.repo
```
🌞 Installer les libs MySQL
Installation des libs MySQL :
```bash
sudo dnf install -y mysql-community-server
```
Installation de KVM (depuis dépôts OpenNebula) :
```bash
sudo dnf install -y opennebula-node-kvm
```
Dépendances supplémentaires :
```bash
sudo dnf install -y genisoimage
```

🌞 Démarrage du service libvirtd
Activation et lancement du service :
```bash
sudo systemctl enable --now libvirtd
```

## 🌞 Ouverture firewall

Configuration des ports nécessaires sur le nœud KVM :
### Commandes exécutées
```bash
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=8472/udp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

🌞 Handle SSH
# SSH sans mot de passe pour OpenNebula

## Objectif
Permettre à `oneadmin` de se connecter à frontend et KVM sans mot de passe ni prompt.

## Commandes principales

### Sur frontend.one
```bash
sudo systemctl enable --now sshd
sudo firewall-cmd --permanent --add-port=22/tcp && sudo firewall-cmd --reload
sudo -iu oneadmin ssh-keygen -t rsa -b 4096 -f /var/lib/one/.ssh/id_rsa -N ''
cat /var/lib/one/.ssh/id_rsa.pub > /var/lib/one/.ssh/authorized_keys
chmod 600 /var/lib/one/.ssh/authorized_keys
ssh -o StrictHostKeyChecking=no oneadmin@localhost
```

# Configuration du Bridge VXLAN pour OpenNebula

Cette étape décrit la création et l’activation d’un bridge réseau VXLAN sur l’hôte `kvm1.one` afin que les VMs puissent communiquer entre elles.

## 1. Création du bridge Linux

```bash
sudo ip link add name vxlan_bridge type bridge
sudo ip link set dev vxlan_bridge up
sudo ip addr add 10.220.220.201/24 dev vxlan_bridge

sudo firewall-cmd --add-interface=vxlan_bridge --zone=public --permanent
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload

**Automatisation avec systemd**
sudo chmod +x /opt/vxlan.sh

**Activer et démarrer le service**
sudo systemctl daemon-reload
sudo systemctl start vxlan
sudo systemctl enable vxlan

