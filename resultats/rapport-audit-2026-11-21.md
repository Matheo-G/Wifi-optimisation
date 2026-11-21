# Rapport final : audit et optimisation Wi-Fi / Freebox

**Date :** 21/11/2026
**Lieu :** Roissy-en-France (95)
**Matériel :** Freebox Pop (v8), ADSL2+ ; répéteur TP-Link TL-WA865RE v6 ; PC Dell (Intel AC 8265)

## 1. Diagnostic

| Élément | Constat | Verdict |
|---|---|---|
| Ligne ADSL | Synchro à 15,4 Mbit/s, environ 12,8 Mbit/s utiles. Aucune erreur non corrigée. **Marge de bruit de 5,7 dB** et **14 coupures en 11 jours** (environ 27 s chacune, souvent la nuit) | Plafond de la maison. Ligne cuivre en fin de vie |
| Wi-Fi de la Freebox | Il fonctionne bien. 2,4 GHz sur le canal 11 saturé, 5 GHz en 160 MHz (portée réduite) | Réglages perfectibles |
| **Répéteur** | Il reçoit bien la box (-55 dB), mais leur liaison était bloquée aux débits du 802.11b. Il distribuait aussi ses propres adresses IP (DHCP) | **Goulot principal : 0,6 Mbit/s derrière lui** |
| PC | Accroché au répéteur alors qu'il capte la Freebox en direct | Mauvais choix de réseau |

## 2. Changements appliqués (un par un, mesurés avant et après)

| # | Changement | Avant | Après |
|---|---|---|---|
| 1 | PC : connexion directe à la Freebox (`RoissyRp`), placée en priorité 1 dans Windows | 0,59 Mbit/s | **12,77 Mbit/s** |
| 2 | Freebox, 2,4 GHz : **802.11ax désactivé** (802.11n gardé, 20 MHz) | Via le répéteur : 0,59 Mbit/s | Via le répéteur : 4,3 à 11,7 Mbit/s |
| 3 | 2,4 GHz : sortie du canal 11 saturé | Canal 11 | **Canal 6**, choisi automatiquement par la box après le changement n°2 |
| 4 | Freebox, 5 GHz : **largeur de 160 à 80 MHz** | Signal du PC 28 %, ping maximal 32 ms | Signal **38 %**, ping maximal **7 ms** |
| 5 | Répéteur : **serveur DHCP désactivé** | Adresses données par le répéteur | Adresses données par la Freebox seule |
| 6 | Branchements téléphoniques | — | Vérifiés par l'utilisateur : ils sont bons |
| 7 | Répéteur : **firmware 1.0.13 → 1.1.0**. Remise à zéro, puis reconfiguration complète (voir `NOTE-config-repeteur.md`) | — | Version 1.1.0 Build 250808, DHCP sur OFF, couverture maximale |

**Résultat final mesuré** (3 téléchargements de 10 Mo, même protocole qu'au départ) :

| Chemin | Début | Fin |
|---|---|---|
| PC → répéteur → Freebox | 0,59 · 0,61 · 0,58 Mbit/s | **8,91 · 9,25 · 10,16 Mbit/s** (×16) |
| PC → Freebox en direct | 12,77 Mbit/s | 10,7 à 12,4 Mbit/s (plafond ADSL) |

**Le réseau intérieur n'est plus le facteur limitant. Seule la ligne ADSL limite encore le débit.**

## 3. Ligne ADSL et fin du cuivre

| | |
|---|---|
| Fermeture commerciale du cuivre à Roissy-en-France | **31 janvier 2027** |
| Fermeture technique (arrêt de l'ADSL) | **31 octobre 2029** |
| Fibre | Commune couverte à environ 97 %, mais **la maison est trop loin de la rue**. Le raccordement demanderait une tranchée ou des poteaux au-dessus des maisons voisines |

Source : comparevite.com, d'après le calendrier d'Orange. Les dates sont à confirmer : elles peuvent encore glisser.

## 4. Recommandations

1. **Court terme :** garder la configuration actuelle. Pour annuler un changement, la marche à suivre est dans `NOTE-config-repeteur.md`.
2. **Moyen terme :** remplacer l'ADSL avant 2029. Sans fibre possible, **Starlink Résidentiel** est l'option conseillée. Une note de synthèse pour le propriétaire a été préparée à part.
3. **Box 4G/5G :** alternative moins chère à comparer, selon la couverture mobile à la maison.
4. **Application Freebox Connect :** retirer de Freebox OS l'application « Audit Wi-Fi (lecture) » si elle y apparaît (Paramètres → Gestion des accès). Elle n'a jamais été autorisée.

## 5. Fichiers du dossier `resultats/`

| Fichier | Contenu |
|---|---|
| `analyse-audit-avant-2026-11-21.md` | Première analyse (Windows) et optimisation n°1 |
| `freebox-lecture-2026-11-21.md` | Ligne ADSL et Wi-Fi de la Freebox |
| `repeteur-lecture-2026-11-21.md` | Le répéteur avant sa mise à jour |
| `NOTE-config-repeteur.md` | Configuration à reproduire et état actuel |
| `audit-windows-*.txt` | Relevés bruts, **non versionnés** : ils contiennent des adresses MAC et l'adresse IPv6 publique |
