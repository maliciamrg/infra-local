# Règles de sécurité opérationnelle

## Interdictions dans le dépôt initial

Aucun playbook ne doit automatiquement :
- créer, détruire, importer ou recréer un pool ZFS ;
- supprimer ou recréer un dataset ;
- modifier les ACL/permissions récursivement ;
- changer les propriétés de `ix-apps`, `.system` ou `boot-pool` ;
- activer les partages SMB qui sont actuellement désactivés ;
- écraser la configuration système TrueNAS.

## Avant d'automatiser une modification

- Identifier précisément la version de TrueNAS et vérifier la documentation de cette version.
- Sauvegarder la configuration et les données.
- Tester sur un dataset de test.
- Lire les permissions/ACL avant et après.
- Prévoir une procédure de retour arrière.

## Particularité des partages

Les partages SMB et les datasets sont deux objets différents. Un partage pointe vers un chemin ; tous les répertoires visibles dans `ls` ne sont pas nécessairement des datasets ZFS.
