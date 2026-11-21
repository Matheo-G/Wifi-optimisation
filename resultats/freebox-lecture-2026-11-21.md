# Lecture de la Freebox (Freebox OS 4.13, 21/11/2026 vers 17 h 15)

Lecture faite dans Freebox OS, sans aucune modification. La box est une Freebox v8 (Pop), API 16.1, allumée depuis 51 jours.

## Ligne ADSL

| | Descendant | Montant |
|---|---|---|
| Protocole | ADSL2+ | |
| Débit brut (synchro) | **15 382 kbit/s** | 1 135 kbit/s |
| Débit IP max observé | 13,9 Mbit/s | 1 Mbit/s |
| Atténuation | 35,5 dB | 18,8 dB |
| **Marge de bruit** | **5,7 dB** (limite basse, l'idéal est 6 dB ou plus) | 8,2 dB |
| CRC / HEC | 0 / 0 | 0 / 0 |
| FEC | 8 510 | 193 |
| ES / SES | 1 007 / 935 | 4 / 0 |
| G.INP | activé (rtx_uc = 0 : toutes les erreurs sont corrigées) | désactivé |
| Mode nitro | activé | activé |

Synchronisée depuis 22 h 55 min.

**Resynchronisations :** l'historique montre **14 coupures de la ligne en 11 jours** (10 au 20 novembre), soit plus d'une par jour.
- Chaque coupure dure environ 27 secondes, puis la ligne se resynchronise entre 14,1 et 14,4 Mbit/s.
- Plusieurs ont lieu la nuit (1 h 55, 3 h 32, 4 h 19), ce qui fait penser à des parasites électriques ou à une marge de bruit trop juste plutôt qu'à un usage.

**Lecture :**
- La ligne est correcte pour de l'ADSL. 35,5 dB d'atténuation correspond à environ 2,5 km du central, ce qui exclut probablement le VDSL2.
- Le débit est proche du maximum possible : environ 14 Mbit/s en synchro.
- La marge de bruit de 5,7 dB est juste. Elle explique probablement les resynchronisations.

## Wi-Fi 5 GHz (`RoissyRp`)

| Paramètre | Valeur |
|---|---|
| Norme | 802.11a/n/ac/ax (Wi-Fi 6) |
| Canal | 36 (secondaire 40) |
| **Largeur** | **160 MHz** |
| MLO | désactivé |

Appareils connectés au moment de la lecture :

| Appareil | Signal | Lien TX / RX |
|---|---|---|
| MacBookAir | **-85 dB** (très faible) | 6 / 216 Mbit/s |
| iPhone | -66 dB | 480 / 97 Mbit/s |
| Apple-GoDay (TV) | -61 dB | 865 / 287 Mbit/s |

**Lecture :**
- 160 MHz est la largeur maximale. Elle donne de gros débits de près, mais **réduit la portée** : la puissance est étalée sur une bande plus large.
- Les appareils éloignés, comme le MacBookAir à -85 dB ou le PC capté à 23-31 %, tiennent mal le 5 GHz.
- Passer en 80 MHz améliorerait la portée, sans perte visible sur Internet puisque l'ADSL plafonne à environ 14 Mbit/s.

## Wi-Fi 2,4 GHz (`RoissyRp`)

| Paramètre | Valeur |
|---|---|
| Norme | 802.11b/g/n/ax. Les cases 802.11n et 802.11ax sont cochées |
| Canal | **automatique**, actuellement 11 |
| Largeur | 20 MHz (bon réglage) |

Appareils connectés :

| Appareil | Signal | Lien TX / RX (Mbit/s) | Remarque |
|---|---|---|---|
| **TL-WA865RE (répéteur)** | **-55 dB (bon)** | **1 / 11** | **Débits de l'ancienne norme 802.11b.** Il a transféré 100,9 Go en 20 jours |
| DELL-FAMILLE (PC) | -82 dB (faible) | 14,4 / 21,7 | Le PC est revenu de lui-même sur le 2,4 GHz après sa bascule en 5 GHz |
| Netatmo Relay ×2 | -63 / -69 dB | 29 / 43 et 1 / 26 | |
| RingStickUpCam | -84 dB | 1 / 11 | Caméra Ring, signal très faible |
| HF-LPB100 | -66 dB | 14 / 65 | Module Wi-Fi d'un objet connecté |

**Lecture :**
- **Le répéteur reçoit bien la Freebox (-55 dB), mais leur liaison tourne à 1 et 11 Mbit/s**, les débits de l'ancienne norme 802.11b.
- Un TL-WA865RE (N300) avec un tel signal devrait négocier entre 130 et 300 Mbit/s. Une liaison bloquée à 11 Mbit/s, partagée en deux par la radio unique du répéteur, explique **directement** les 0,6 Mbit/s mesurés derrière le répéteur.
- Les débits affichés pour un appareil peu actif peuvent retomber au minimum. Il faut donc vérifier côté répéteur (mode sans fil, firmware) et sous charge.
- Causes probables :
  - un répéteur ancien qui négocie mal avec le 802.11ax (Wi-Fi 6) de la Freebox ;
  - un répéteur réglé en mode « b/g » ;
  - un firmware ancien.
