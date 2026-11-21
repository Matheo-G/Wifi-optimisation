# Lecture du répéteur TP-Link (21/11/2026 vers 17 h 25)

Lecture faite dans l'interface web du répéteur (http://192.168.1.199), sans aucune modification. Le mot de passe admin a été tapé par l'utilisateur.

## Identité

| | |
|---|---|
| Modèle | **TL-WA865RE**, version matérielle **6.0** (N300, 2,4 GHz seulement) |
| Firmware | **1.0.13 Build 231115** Rel.51785n (novembre 2023) |
| Mode | Répéteur Wi-Fi (Range Extender) |
| IP | 192.168.1.199, en IP dynamique ; passerelle et DNS 192.168.1.254 |

## Liaison avec la Freebox

| | |
|---|---|
| Réseau hôte | `RoissyRp`, 2,4 GHz |
| Signal (vu par le répéteur) | 4 barres sur 5 |
| Signal (vu par la Freebox) | -55 dB |
| **Débit de liaison (vu par la Freebox)** | **1 Mbit/s TX / 11 Mbit/s RX, des débits de la norme 802.11b** |

## Réseau étendu

| | |
|---|---|
| SSID | `RoissyRp_EXT` |
| Canal | 11, imposé par le canal de la Freebox |
| Clients connectés au répéteur | 1 au moment de la lecture |
| Couverture Wi-Fi (puissance) | Maximale |

## Serveur DHCP du répéteur

| | |
|---|---|
| Mode | **Auto** |
| Plage | **192.168.1.200 à 192.168.1.250**, bail de 120 min |

Ce répéteur distribue lui-même des adresses aux appareils qui passent par lui : le PC a reçu `.201` du serveur `.199`. Cette plage peut chevaucher celle de la Freebox, qui a donné `.175` au PC, d'où un **risque de conflit d'adresses**.

## Ce que l'interface ne permet pas

Cette interface simplifiée ne propose ni le choix du mode radio (b/g/n), ni la largeur de canal, ni l'affichage du débit négocié. La liaison à 11 Mbit/s ne peut donc se corriger que **côté Freebox** (réglages 2,4 GHz) ou par une mise à jour du firmware.

> Note : la carte réseau du répéteur affiche la clé Wi-Fi en clair. Elle n'a été ni relevée ni enregistrée ici.
