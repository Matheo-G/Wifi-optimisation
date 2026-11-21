# Note : configuration du répéteur TP-Link TL-WA865RE

Configuration relevée le 21/11/2026, **avant** la mise à jour du firmware 1.0.13 → 1.1.0. Installée directement, la 1.1.0 remet le répéteur en réglages d'usine.

> **Aucun mot de passe ni aucune clé Wi-Fi ne figure dans cette note.** Tu devras taper toi-même :
> - **la clé Wi-Fi de la Freebox** (réseau `RoissyRp`). Elle est notée sur l'étiquette de la Freebox, ou dans Freebox OS → Paramètres → Wi-Fi → Configuration Réseau ;
> - **un mot de passe admin** pour l'interface du répéteur. Il sera demandé au premier accès après la remise à zéro.

## Configuration à reproduire

| Réglage | Valeur avant la mise à jour | Où le régler |
|---|---|---|
| Modèle / matériel | TL-WA865RE **v6.0** | (info) |
| Firmware | 1.0.13 Build 231115 → **1.1.0 Build 250808** | Outils système → Mise à jour du firmware |
| Mode | **Répéteur Wi-Fi (Range Extender)**, pas Point d'accès | Changer de mode (en haut) |
| Réseau hôte | **`RoissyRp`**, 2,4 GHz (Wi-Fi de la Freebox) | Installation rapide |
| Mot de passe du réseau hôte | la clé Wi-Fi de la Freebox (**à taper toi-même**) | Installation rapide |
| SSID étendu | **`RoissyRp_EXT`**, en gardant le suffixe `_EXT` pour savoir où l'on est connecté | Installation rapide ou onglet WiFi |
| Mot de passe du réseau étendu | **le même que la Freebox** (le répéteur le copie par défaut) | Installation rapide |
| Canal | aucun réglage : le répéteur suit le canal de la Freebox (6 actuellement) | — |
| Adresse IP | **automatique (DHCP de la Freebox)**. Elle était `192.168.1.199` avant | Réglages → Réseau → Paramètres LAN |
| **Serveur DHCP** | **Inactif** ⚠️ à remettre absolument (par défaut, il revient sur « Auto ») | Réglages → Réseau → Serveur DHCP → Inactif → Enregistrer |
| Couverture Wi-Fi | **Maximale** | Réglages → Réglages avancés → Couverture WiFi |
| Calendrier d'alimentation, contrôle d'accès, LED | non relevés : la session a expiré. Réglages d'usine attendus | Réglages → Réglages avancés |

## Comment se reconnecter au répéteur après la remise à zéro

1. Le répéteur redémarre avec un **réseau Wi-Fi ouvert par défaut**, du type `TP-Link_Extender` (ou `TP-Link_Extender_XXXX`).
2. Sur le PC, connecte-toi à ce réseau. Pas de mot de passe.
3. Ouvre **http://tplinkrepeater.net** (ou http://192.168.0.254) dans le navigateur.
4. Crée un **mot de passe admin**.
5. Lance l'**Installation rapide** :
   - choisis **`RoissyRp`** dans la liste des réseaux 2,4 GHz ;
   - tape la **clé Wi-Fi de la Freebox** ;
   - nomme le réseau étendu **`RoissyRp_EXT`**, en gardant le même mot de passe que la Freebox ;
   - valide : le répéteur redémarre.
6. Reconnecte le PC à `RoissyRp`. Le répéteur reçoit une nouvelle adresse de la Freebox : Freebox OS → Périphériques réseau → `TL-WA865RE`. Ouvre son interface à cette adresse ou via http://tplinkrepeater.net.
7. Remets le **serveur DHCP sur « Inactif »** et la **couverture sur « Maximale »**.
8. Vérifie : un appareil connecté à `RoissyRp_EXT` doit recevoir une adresse donnée par `192.168.1.254` (la Freebox).

## État après la mise à jour (21/11/2026, fin d'après-midi) ✅

| Réglage | État vérifié |
|---|---|
| Firmware | **1.1.0 Build 250808** Rel.34045n |
| Réseau hôte / SSID étendu | `RoissyRp` / **`RoissyRp_EXT`**, canal 6 |
| Adresse IP | 192.168.1.199, dynamique (donnée par la Freebox) |
| Serveur DHCP | **OFF** (dans le nouveau firmware, « Inactif » s'appelle « OFF ») |
| Couverture Wi-Fi | Maximale |
| Accès à l'interface | désormais en **HTTPS** : https://192.168.1.199. L'avertissement de certificat de Chrome est normal |

Débit Internet à travers le répéteur : **8,9 à 10,2 Mbit/s**, contre 0,6 Mbit/s au début de l'audit.

## Réglages de la Freebox modifiés pendant l'audit (pour mémoire)

| Réglage | Avant | Après |
|---|---|---|
| 2,4 GHz : 802.11ax | activé | **désactivé** (802.11n gardé, 20 MHz, canal automatique) |
| 5 GHz : largeur de bande | 160 MHz | **80 MHz** |
| PC : priorité Wi-Fi Windows | `RoissyRp_EXT` d'abord | **`RoissyRp` d'abord** |
