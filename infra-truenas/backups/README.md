# Sauvegardes TrueNAS

Avant une mise à jour majeure, une modification des partages ou une opération ZFS :

1. Dans l'interface Web TrueNAS, télécharge une sauvegarde de la configuration système (System Settings / General / Manage Configuration ; le libellé peut varier).
2. Stocke-la sur un autre appareil ou un stockage indépendant.
3. Ne la place pas dans Git : elle peut contenir des informations sensibles.
4. Sauvegarde séparément les données importantes des pools.
5. Teste régulièrement la restauration des fichiers et, si possible, la procédure de restauration de configuration.

Une sauvegarde de configuration TrueNAS ne remplace pas une sauvegarde des datasets.
