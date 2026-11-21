# Contexte projet : audit et optimisation Wi-Fi (reprise en local)

Ce fichier est lu automatiquement par Claude Code. Il résume tout ce qui a été fait dans la première session (cloud, sans accès au réseau local).

## Mission (demandée par l'utilisateur)
Expert réseau Wi-Fi et Freebox. Réaliser un **audit complet**, puis une **optimisation one-shot** du réseau domestique, **sans acheter de matériel**.
1. Déterminer si la limitation vient de la ligne ADSL, du Wi-Fi, du répéteur ou d'un mauvais réglage.
2. Récupérer les infos de la Freebox, du répéteur, du réseau local et des appareils connectés.
3. Vérifier :
   - le lien PC ↔ répéteur et le lien répéteur ↔ Freebox ;
   - la bande et le canal utilisés ;
   - les interférences ;
   - les performances réelles.
4. Proposer les optimisations **par ordre d'impact** : problème, niveau d'impact, action, gain attendu.
5. Appliquer les optimisations **une par une**, en mesurant avant et après chacune.
6. Produire un **rapport final** : performances avant/après, paramètres modifiés, recommandations.

## Règles impératives
- **Ne jamais modifier un paramètre sans expliquer ce qui va être fait et obtenir la validation explicite de l'utilisateur.**
- Ne jamais réinitialiser la Freebox. Ne jamais couper Internet inutilement. Aucune modification risquée.
- Privilégier les outils déjà présents sur le PC. Avant d'installer un logiciel gratuit, expliquer pourquoi.
- Répondre en français.
- Ne jamais afficher, enregistrer ou committer la clé Wi-Fi, les mots de passe admin ou un token d'API Freebox.

## Configuration
- FAI Free, **Freebox Pop**, connexion **ADSL**, synchro descendante **13,8 Mbit/s**. Plafond utile estimé : environ 11,8 Mbit/s, soit environ 1,5 Mo/s.
- Maison sur 3 niveaux (RDC, 1er, 2e). La Freebox est dans la maison (étage à confirmer).
- **Répéteur TP-Link N300 (2x2)** au 1er étage. Il est en 2,4 GHz uniquement et sa radio unique divise le débit par 2.
- Le PC de l'utilisateur est connecté en Wi-Fi au répéteur. Système probablement Windows, à vérifier.
- Le problème est le **débit**, pas la couverture.

## Mesures déjà faites (21/11/2026, banc de débit dans le navigateur)
| Config | Débit médian | Essais (Mbit/s) | Gigue | Lecture |
|---|---|---|---|---|
| Direct Freebox, même pièce | **12,15** | 11,88 · 12,26 · 12,15 | 4 ms | Plafond ADSL atteint : la Freebox et son Wi-Fi vont bien |
| Répéteur, place habituelle | **0,47** | 0,50 · 0,37 · 0,47 | 118 ms | Effondrement, liaison très instable |
| Répéteur, place habituelle | 42,49 | 26 · 42 · 44 | 36 ms | **Invalide** (supérieur à la synchro). Bug de la v1 du banc, ou appareil sur un autre réseau : à demander à l'utilisateur |

Le ping de ces mesures va jusqu'au serveur de la page, pas jusqu'à la Freebox : ne pas l'interpréter comme une latence locale.

**Diagnostic provisoire :**
1. La ligne ADSL est le plafond absolu pour Internet.
2. **Le répéteur est le goulot**, de façon intermittente.

Causes à vérifier en priorité :
- signal faible entre la Freebox et le répéteur ;
- canal 2,4 GHz encombré ou réglé en 40 MHz ;
- sécurité TKIP ou WPA/WPA2 mixte (bride à 54 Mbit/s) ;
- Freebox Player/TV qui consomme l'ADSL ;
- PC qui reste accroché au répéteur alors que la Freebox est joignable en 5 GHz.

## Ce qui reste à faire (dans l'ordre)
1. **Collecte automatique** (maintenant possible en local) :
   - lancer `scripts/audit-wifi-windows.ps1 -Label avant-repeteur` (lecture seule) ; il donne le signal, le canal, la bande, la vitesse de liaison, les réseaux voisins, les pings vers la passerelle et la Freebox (192.168.1.254 par défaut) et le débit ;
   - à défaut, lancer directement `netsh wlan show interfaces`, `netsh wlan show networks mode=bssid` et `netsh wlan show drivers`.
2. **Freebox** : passer par l'API Freebox OS (`http://mafreebox.freebox.fr/api/v8/…`).
   - L'appli doit être autorisée une fois. Prévenir l'utilisateur que la demande s'affiche dans Freebox OS ou dans l'app Freebox Connect, et qu'il doit l'accepter.
   - Demander **uniquement les droits de lecture nécessaires**. Ne pas stocker le token dans le dépôt.
   - À récupérer :
     - l'état xDSL : modulation, débit ATM, marge de bruit, atténuation, CRC/FEC, nombre de resynchronisations ;
     - la config Wi-Fi des deux bandes : canal, largeur, sécurité ;
     - la liste des appareils connectés.
   - À défaut, demander à l'utilisateur des captures d'écran de Freebox OS.
3. **Répéteur** (http://tplinkrepeater.net ou son IP) :
   - modèle exact et firmware ;
   - mode (Range Extender ou Point d'accès) ;
   - force du signal reçu de la Freebox ;
   - SSID (identique à la Freebox ou suffixé `_EXT`) et canal.

   Le mot de passe admin est tapé par l'utilisateur lui-même.
4. Refaire au moins un test « Répéteur · place habituelle » avec le banc corrigé (v2).
5. Produire le **rapport d'audit** (problèmes, impact, actions, gain attendu), puis appliquer les optimisations **une par une après validation**, avec une mesure après chacune (`-Label apres-1`, `apres-2`…, plus le banc avec la config « Après optimisation N »).
6. Rapport final.

## Pistes d'optimisation pressenties (à confirmer par les données)
1. Si la Freebox est joignable en 5 GHz depuis le PC avec un signal correct : connecter le PC **directement à la Freebox en 5 GHz** plutôt qu'au répéteur. C'est le plus gros gain possible.
2. Sécurité en **WPA2-AES** (ou WPA2/WPA3), jamais TKIP.
3. 2,4 GHz sur un **canal fixe 1, 6 ou 11**, le moins occupé d'après le scan des voisins, en **20 MHz**.
4. **Déplacer le répéteur** à mi-chemin, à un endroit où il reçoit au moins 60-70 % du signal de la Freebox (vérifier escaliers, murs porteurs, électroménager).
5. Mettre à jour le firmware du répéteur (à valider avant). Utiliser un SSID distinct `_EXT` pour savoir où le PC est connecté.
6. Vérifier que la TV Freebox ou d'autres appareils ne saturent pas l'ADSL pendant l'usage.
7. Long terme : vérifier l'éligibilité à la fibre ou au VDSL2. La Freebox Pop est compatible fibre, c'est un changement d'abonnement, pas un achat de matériel.

## Fichiers du dépôt
- `README.md` : pré-diagnostic et marche à suivre pour l'utilisateur.
- `scripts/audit-wifi-windows.ps1` : audit Windows en lecture seule. **Jamais exécuté ni testé** : le corriger si besoin. Lancement : `powershell -ExecutionPolicy Bypass -File .\scripts\audit-wifi-windows.ps1 -Label <nom>`.
- `scripts/audit-wifi-macos.sh` : équivalent macOS.
- `outils/banc-debit.html` : source du banc de débit publié sur https://claude.ai/artifact/4HZK9wrbsPYLm2DZH2w9JJ.
  - Il fait 3 téléchargements de 4 Mo, mesure la latence et enregistre chaque résultat avec sa configuration.
  - Les mesures sont stockées dans la base de l'artifact (collection `mesures`), lisible avec l'outil ArtifactData si disponible.
- `resultats/` : sorties des scripts et relevés de mesures (`mesures-2026-11-21.md`).

## Git
Branche de travail : `ccr-4b3e3874-0y1le2`. Committer les résultats et rapports au fil de l'eau, sans aucune donnée sensible.
