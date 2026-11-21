# Analyse de l'audit « avant » (21/11/2026, 14 h 28)

Source : `audit-windows-avant-20261121-1428.txt` (script en lecture seule, PC Dell sous Windows 10 Pro, carte Intel AC 8265 bi-bande).

## Constats

| Élément | Mesure | Lecture |
|---|---|---|
| Réseau du PC | `RoissyRp_EXT` (répéteur), 2,4 GHz, canal 11, 802.11n, WPA2-AES (CCMP) | Pas de TKIP : la sécurité ne bride pas |
| Lien PC ↔ répéteur | Signal 87-91 %, liaison 130-144 Mbit/s, stable sur 30 s | **Excellent** : ce lien n'est pas le problème |
| Ping vers la Freebox (192.168.1.254) | 6 ms en moyenne, 3-54 ms, 2 % de perte | Correct à vide |
| Ping vers Internet (1.1.1.1) | 24 ms, 0 % de perte | Ligne ADSL saine à vide |
| **Débit descendant** | **0,59 · 0,61 · 0,58 Mbit/s** | **Effondré** : environ 5 % du plafond ADSL (~12 Mbit/s) |
| Débit montant | 0,92 Mbit/s | Normal pour de l'ADSL |

## Réseau principal (Freebox) vu depuis le PC

La passerelle 192.168.1.254 a la MAC `38:07:16:0c:fd:d0`, qui est aussi l'identifiant du réseau `RoissyRp`. **`RoissyRp` est donc le Wi-Fi de la Freebox.**

- 5 GHz, canal 36 : signal **40 %**
- 2,4 GHz, canal 11 : signal **62 %**

Le profil `RoissyRp` est déjà enregistré sur le PC, donc on peut basculer dessus sans retaper la clé.

## Occupation du 2,4 GHz

Le canal 11 est saturé. On y trouve :
- la Freebox (`RoissyRp`) ;
- le répéteur (`RoissyRp_EXT`) ;
- `Roissycoloc` (50 %) ;
- **un partage de connexion `Redmi Note 10 Pro` à 96 %**, donc un téléphone tout près du PC.

Le répéteur, qui n'a qu'une radio, doit rester sur le même canal que la Freebox. Chaque paquet traverse donc deux fois ce canal encombré.

## Diagnostic

1. Le lien PC ↔ répéteur est excellent et la ligne ADSL est saine. **La perte se fait entre le répéteur et la Freebox**, et/ou à cause de l'encombrement du canal 11.
2. Un débit descendant inférieur au débit montant sur de l'ADSL est anormal. Cela confirme un goulot sur le chemin Wi-Fi de la Freebox vers le PC.

## Point annexe à vérifier

Le serveur DHCP est **192.168.1.199**, et non la Freebox (.254). Il faut identifier cet appareil. Un second serveur DHCP sur le réseau peut causer des coupures et des conflits.

## Prochaines actions proposées (à valider une par une)

1. **Test réversible** : connecter le PC directement à `RoissyRp` (la Freebox, en 5 GHz de préférence) et refaire la mesure (`-Label apres-1`).
2. Couper le partage de connexion du Redmi s'il n'est pas utilisé, puis remesurer.
3. Lire la configuration de la Freebox (API, en lecture seule) et du répéteur : signal reçu par le répéteur, largeur de canal, appareils connectés, consommation de la TV.

## Optimisation n°1 : PC connecté directement à la Freebox (21/11/2026, 14 h 44)

Source : `audit-windows-apres-1-freebox-direct-20261121-1444.txt`. Le PC est sur `RoissyRp`, en 2,4 GHz, canal 11. Windows a choisi le 2,4 GHz parce que le 5 GHz n'est capté qu'à 23-31 % à cet endroit.

| Mesure | Avant (répéteur) | Après 1 (Freebox directe) |
|---|---|---|
| Signal | 87-91 % | 45-51 % |
| Vitesse de liaison | 130-144 Mbit/s | 29-58 Mbit/s |
| Ping vers la Freebox | 6 ms, 2 % de perte | **3 ms, 0 % de perte** |
| Ping vers Internet | 24 ms | 25 ms |
| **Débit descendant** | **0,59 Mbit/s** | **12,77 Mbit/s (×21)** |
| Débit montant | 0,92 Mbit/s | 0,88 Mbit/s |

**Conclusion :** avec un signal deux fois plus faible, le PC atteint le plafond de la ligne ADSL (environ 12,2 Mbit/s mesurés en direct le matin). **Le répéteur était la seule cause du problème de débit.** Même avec un signal moyen, une liaison directe à environ 50 Mbit/s reste quatre fois plus rapide que la ligne ADSL.
