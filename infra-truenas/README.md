# infra-truenas

Dépôt de documentation et d'inventaire pour TrueNAS SCALE 25.10.3.1 (Goldeye).

**Mode prudent par défaut :** ce dépôt décrit l'installation connue et fournit des outils d'audit en lecture seule. Il ne crée, ne détruit et ne modifie aucun pool, dataset, ACL ou partage SMB automatiquement.

## État connu de l'installation

- Modèle : TerraMaster F4-425
- TrueNAS SCALE : 25.10.3.1 (Goldeye)
- Pools :
  - `BigBoy` : disque unique, pas de redondance
  - `DataSafe` : miroir de deux disques, environ 4,32 Go disponibles au dernier relevé
  - `Ssd1to` : disque unique, pas de redondance
  - `boot-pool` : pool système TrueNAS
- Les datasets `ix-apps`, `.system` et `boot-pool` sont considérés comme protégés.
- Les partages SMB sont répertoriés dans `inventory/smb-shares.yml`.

Les capacités et états sont un instantané du dernier inventaire communiqué ; ils peuvent évoluer.

## Arborescence

- `inventory/` : inventaire déclaratif de l'état observé.
- `scripts/` : commandes d'audit utilisant `midclt` localement sur TrueNAS.
- `ansible/` : playbook de collecte en lecture seule via SSH.
- `backups/` : procédure de sauvegarde de la configuration TrueNAS.
- `docs/` : notes sur les limites et précautions.

## Utilisation

### 1. Initialiser Git

```bash
git init
git add .
git commit -m "Inventaire initial TrueNAS"
```

### 2. Actualiser l'inventaire depuis TrueNAS

Copie `scripts/collect-inventory.sh` sur TrueNAS, puis lance-le en SSH avec un compte administrateur autorisé à exécuter `midclt` :

```bash
chmod +x collect-inventory.sh
./collect-inventory.sh
```

Le script affiche les sorties JSON de `pool.query`, `pool.dataset.query`, `sharing.smb.query` et `disk.query`. Il ne modifie rien. Compare les résultats aux fichiers YAML du dépôt et mets-les à jour manuellement.

> Le script ne copie pas automatiquement les sorties dans ce dépôt et ne constitue pas une sauvegarde de configuration. Il évite ainsi de committer par inadvertance des informations sensibles.

### 3. Audit depuis un poste avec Ansible

Installe Ansible et la collection POSIX si nécessaire :

```bash
ansible-galaxy collection install ansible.posix
cp ansible/inventory/hosts.example.yml ansible/inventory/hosts.yml
```

Adapte l'hôte, l'utilisateur et la clé SSH, puis exécute :

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/audit.yml
```

Le playbook ne fait que lire l'état ZFS et SMB via `midclt` sur TrueNAS.

## Important : avant toute modification

1. Télécharge une sauvegarde de la configuration TrueNAS depuis l'interface Web (System Settings / General / Manage Configuration selon l'interface).
2. Garde cette sauvegarde hors du NAS et hors de Git.
3. Vérifie les sauvegardes des données. Un miroir ZFS n'est pas une sauvegarde.
4. Ne modifie pas les ACL globalement pour rendre un partage accessible.
5. Ne place pas de base PostgreSQL sur SMB/CIFS.
6. Ne supprime ni ne recrée les pools ou datasets protégés.

## API TrueNAS

TrueNAS SCALE 25.10 utilise son interface API moderne. Les appels `midclt` de ce dépôt sont destinés à être exécutés localement sur TrueNAS. Pour une automatisation distante, privilégie l'API documentée de la version installée et une clé API dédiée, avec permissions minimales. N'invente pas de méthode d'API à partir d'anciens exemples REST.

## Inventaire initial

Les fichiers YAML reprennent les informations communiquées dans cette conversation. Les propriétés ZFS non relevées sont marquées comme inconnues ou omises : elles ne doivent pas être interprétées comme des valeurs par défaut garanties.
