# Audit et optimisation Wi-Fi : Freebox Pop (ADSL) + répéteur TP-Link N300

Tout le dossier `scripts/` est **en lecture seule** : il ne modifie aucun paramètre du PC, de la Freebox ni du répéteur.
Les résultats sont enregistrés dans `resultats/`.

---

## 1. Pré-diagnostic (avant toute mesure)

| # | Piste | Pourquoi | Impact probable |
|---|-------|----------|-----------------|
| 1 | **La ligne ADSL plafonne tout** | Une synchro de 13,8 Mbit/s donne environ **11,5 à 12 Mbit/s utiles** (≈ 1,4 à 1,5 Mo/s) à cause de l'overhead ATM/PPP. Aucun réglage Wi-Fi ne peut dépasser ce plafond pour Internet. | 🔴 Très élevé |
| 2 | **Le répéteur N300 divise le débit par 2** | Il ne fonctionne qu'en 2,4 GHz avec une seule radio : il reçoit de la Freebox et réémet vers le PC sur le **même canal**, à tour de rôle. Débit réel typique : 15 à 40 Mbit/s, et parfois **moins de 12 Mbit/s** si le lien répéteur → Freebox est faible ou brouillé. Il peut alors devenir le goulot. | 🟠 Élevé |
| 3 | **Sécurité WPA/TKIP ou mode mixte** | En TKIP, le 802.11n est **bridé à 54 Mbit/s** de liaison, soit environ 20 Mbit/s réels, divisés par 2 avec le répéteur. Il faut du WPA2-AES (ou WPA2/WPA3). | 🟠 Élevé si présent |
| 4 | **Canal 2,4 GHz encombré ou largeur 40 MHz** | Les voisins sur le même canal causent des collisions et des retransmissions. Il faut un canal fixe 1, 6 ou 11, en 20 MHz. | 🟡 Moyen |
| 5 | **Freebox Player / TV qui consomme l'ADSL** | Un flux TV peut prendre 4 à 8 Mbit/s sur les 12 disponibles. | 🟠 Élevé quand la TV est allumée |
| 6 | **Appareils en arrière-plan** | Mises à jour, cloud, consoles… | 🟡 Variable |
| 7 | **PC capable de 5 GHz mais bloqué sur le répéteur** | Si la Freebox est assez proche, la connexion directe en 5 GHz est bien plus rapide que le répéteur. | 🟡 Moyen |

**Test décisif :** comparer le débit Internet **(a)** via le répéteur, **(b)** en Wi-Fi à côté de la Freebox, **(c)** en câble Ethernet sur la Freebox si c'est possible.
Si les trois donnent environ 11-12 Mbit/s, c'est la ligne ADSL qui limite, et le Wi-Fi n'y est pour rien.

---

## 2. Ce que je te demande de faire

### Étape A : lancer le script d'audit (environ 3 min, Internet n'est pas coupé)

**Windows** (PowerShell, depuis le dossier du projet) :
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-wifi-windows.ps1 -Label avant-repeteur
```
`-ExecutionPolicy Bypass` ne vaut que pour cette exécution : aucun changement permanent.

**macOS** :
```bash
bash scripts/audit-wifi-macos.sh avant-repeteur
```

Lance-le **deux fois** :
1. `-Label avant-repeteur` : PC à sa place habituelle, connecté au répéteur ;
2. `-Label avant-direct` : PC dans la pièce de la Freebox, connecté **directement à la Freebox** (de préférence en 5 GHz).

> Pendant les tests : TV Freebox éteinte, et pas de téléchargement ni de streaming sur les autres appareils.

### Étape B : infos Freebox (interface web, lecture seule)
Ouvre http://mafreebox.freebox.fr et connecte-toi, puis relève :

- **Paramètres de la Freebox › État de la Freebox › Internet / xDSL** :
  - modulation (ADSL2+ / VDSL2), débit ATM descendant et montant ;
  - **marge de bruit (SNR)** et **atténuation**, en descendant et en montant ;
  - compteurs **CRC / FEC / HEC**, durée de connexion, nombre de resynchronisations.
- **Paramètres › Wi-Fi** (une ligne par bande, 2,4 GHz et 5 GHz) :
  - état, **canal** (auto ou fixe), **largeur de canal**, norme ;
  - **type de sécurité** (WPA2 / WPA3 / mixte / TKIP ?) ;
  - SSID unique ou séparé par bande.
- **Périphériques réseau** : la liste des appareils connectés (une capture d'écran suffit).

### Étape C : infos répéteur TP-Link
Ouvre http://tplinkrepeater.net (ou l'IP du répéteur) et relève :
- le modèle exact (étiquette : TL-WA850RE, TL-WA855RE, RE200…) et la version du firmware ;
- le **mode** (Range Extender / Point d'accès) ;
- la **force du signal reçu de la Freebox** (le % ou les barres) ;
- le SSID étendu (identique à la Freebox ou suffixé `_EXT`) et le canal.

### Étape D : me renvoyer tout ça
Colle le contenu des fichiers `resultats/audit-*.txt` et les relevés B/C dans la conversation (ou ajoute-les dans `resultats/`).
**Masque la clé Wi-Fi** si elle apparaît : le script ne l'affiche pas.

---

## 3. Ensuite
1. J'analyse et je produis le **rapport d'audit** : problèmes, impact, actions, gain attendu.
2. On applique les optimisations **une par une, après ta validation**, et on relance le script avec `-Label apres-1`, `apres-2`… pour comparer avant/après.
3. À la fin, je rédige le rapport récapitulatif : performances avant/après, paramètres modifiés, recommandations.
