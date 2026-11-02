# infra-ubuntu

Modèle de dépôt pour reconstruire un Ubuntu Server et relancer Frigate, Ollama et Paperless-ngx.

## Ce que fait ce dépôt

- Ansible prépare Ubuntu : paquets, Docker et répertoires de travail.
- Docker Compose décrit séparément chaque application.
- Les fichiers `.env` contiennent les paramètres locaux et secrets (ils ne doivent pas être commités).
- Les données applicatives sont conservées dans `/srv`; la base PostgreSQL de Paperless reste sur le disque local.

**Ce dépôt ne modifie pas TrueNAS.** Les montages SMB sont volontairement à configurer après avoir confirmé les partages réellement exportés par TrueNAS.

## 1. Préparer le dépôt

Sur ton PC d'administration :

```bash
sudo apt update
sudo apt install ansible
cd infra-ubuntu
cp inventory/hosts.example.yml inventory/hosts.yml
```

Modifie `inventory/hosts.yml` avec l'adresse IP ou le nom DNS de ton Ubuntu et ton utilisateur SSH.

## 2. Préparer Ubuntu

Vérifie d'abord la connexion SSH :

```bash
ansible -i inventory/hosts.yml ubuntu -m ping
```

Puis lance :

```bash
ansible-playbook -i inventory/hosts.yml playbooks/install.yml --ask-vault-pass--ask-vault-pass
```

Le playbook installe les paquets Ubuntu `docker.io`, `docker-compose-v2` et `cifs-utils`, active Docker et ajoute l'utilisateur Ansible au groupe `docker`.
Après l'ajout au groupe, reconnecte-toi à Ubuntu pour que le nouveau groupe soit pris en compte.

> Selon la version d'Ubuntu et ses dépôts activés, le nom ou la disponibilité des paquets peut varier. Vérifie le résultat du playbook avant de poursuivre.

## 3. Configurer les applications

Pour chaque application, copie son exemple d'environnement :

```bash
cp docker/frigate/.env.example docker/frigate/.env
cp docker/ollama/.env.example docker/ollama/.env
cp docker/paperless/.env.example docker/paperless/.env
```

Édite les `.env`, puis vérifie les chemins et paramètres dans chaque `compose.yml`.

Les répertoires par défaut sont locaux :
- `/srv/frigate`
- `/srv/ollama`
- `/srv/paperless`

Ils sont créés par Ansible. Tu peux les déplacer vers des montages NAS une fois les partages SMB configurés et testés.

## 4. Démarrer les conteneurs

Depuis le répertoire du dépôt :

```bash
docker compose --env-file docker/frigate/.env -f docker/frigate/compose.yml up -d
docker compose --env-file docker/ollama/.env -f docker/ollama/compose.yml up -d
docker compose --env-file docker/paperless/.env -f docker/paperless/compose.yml up -d
```

Pour voir les journaux :

```bash
docker compose --env-file docker/frigate/.env -f docker/frigate/compose.yml logs -f
```

Pour mettre à jour une application :

```bash
docker compose --env-file docker/frigate/.env -f docker/frigate/compose.yml pull
docker compose --env-file docker/frigate/.env -f docker/frigate/compose.yml up -d
```

## 5. Points à personnaliser impérativement

### Frigate
- Ajoute ta configuration caméra dans `docker/frigate/config/config.yml`.
- Configure les flux RTSP et les mots de passe dans ce fichier ou dans des secrets adaptés.
- L'accélération `/dev/dri` est un exemple commenté : active-la uniquement si le matériel et les pilotes Ubuntu le permettent.
- Le port 5000 n'est pas publié sur l'hôte ; l'interface habituelle passe par 8971.

### Ollama
- L'API est publiée sur le port 11434. Ne l'expose pas directement à Internet.
- Le stockage des modèles est dans `/srv/ollama`.
- L'accès GPU est laissé désactivé par défaut. Il dépend du matériel et des pilotes.

### Paperless-ngx
- PostgreSQL utilise un volume Docker local nommé `paperless-db`. C'est volontaire : évite de placer le répertoire de données PostgreSQL sur SMB/CIFS.
- Les dossiers `data`, `media`, `export` et `consume` sont sous `/srv/paperless`.
- Place les documents à importer dans `consume`.
- Configure un mot de passe fort et garde les sauvegardes de la base et des documents ensemble.

## 6. Sauvegarde avant réinstallation

Une réinstallation Ubuntu ne doit pas être considérée comme une sauvegarde. Avant de réinstaller :
- sauvegarde les répertoires `/srv/frigate`, `/srv/ollama` et `/srv/paperless`;
- sauvegarde les volumes Docker, notamment `paperless-db`, avec une méthode cohérente PostgreSQL (`pg_dump` ou arrêt propre + sauvegarde du volume);
- conserve les fichiers `.env` et les secrets hors du dépôt Git, dans un endroit sûr;
- vérifie que les données NAS sont sauvegardées indépendamment.

**Attention à DataSafe :** lors de l'inventaire, il ne restait qu'environ 4,32 Go disponibles. Ne dirige pas de nouvelles données vers ce pool avant d'avoir libéré de l'espace ou augmenté sa capacité.

## 7. Git et secrets

Le `.gitignore` exclut les vrais fichiers `.env`, les clés et les données. Ne force jamais l'ajout de secrets avec `git add -f`.

```bash
git init
git add .
git commit -m "Initial infrastructure"
```

## 8. Limites de ce modèle

Ce dépôt est un point de départ à adapter. Il ne recrée pas les configurations internes de TrueNAS, les partages SMB, les caméras Frigate, les comptes Paperless ni les modèles Ollama. Teste chaque service et ses sauvegardes avant de considérer la reconstruction comme validée.
