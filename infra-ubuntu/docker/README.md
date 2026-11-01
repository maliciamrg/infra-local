Chaque sous-dossier contient un `compose.yml` indépendant et un `.env.example`.
Copie `.env.example` en `.env` avant le démarrage. Ne versionne jamais les `.env`.
Les chemins `/srv/...` sont locaux par défaut. N'utilise un chemin NAS qu'après
avoir monté le partage SMB sur Ubuntu et vérifié qu'il est accessible au démarrage.
