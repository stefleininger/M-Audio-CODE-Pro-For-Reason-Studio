# M-Audio Code 25 — Codec Remote & Mapping pour Reason Studio

Codec de surface de contrôle personnalisé (**Lua Remote**) et fichier de mappage (`.remotemap`) conçus pour exploiter le **M-Audio Code 25** dans **Reason** avec un retour visuel par LED via **SysEx**, un moteur de **modes XY** et une structure modulaire facile à maintenir.

---

## Fonctionnalités et améliorations apportées

### 1. Retour d'état visuel par LED via SysEx (`port = 2`)
* **Protocole dédié :** envoi de trames SysEx sur le port de sortie LED configuré (`LED_OUTPUT_PORT = 2`), avec ouverture et fermeture de session (`remote_prepare_for_use` / `remote_release_from_use`) et commande d'écriture (`67`) :
  `F0 00 01 05 7F 31 04 67 00 00 00 <HI> <LO> 00 <COLOR> F7`.
* **Table centralisée `LED_BUTTONS` (Boutons 1 à 16) :** factorisation de la configuration des boutons suivis (index Remote, adresses `OFF` / `ON`, couleurs active/inactive et mémorisation du dernier état `last_on`) afin d'éviter la duplication de code et d'éviter les trames redondantes.
* **Suivi d'état via `output="value"` et `remote_set_state` :** lecture de l'état courant des paramètres via `remote.get_item_value(...)` et mise en file d'attente des messages dans `pendingLedMessages`, livrés par `remote_deliver_midi` en vérifiant la taille de tampon disponible (`max_bytes >= 16`).

### 2. Moteur de modes XY (Boutons 17 à 20 + XY Pad)
* **Quatre modes commutables (CC 28 à 31) :**
  * **Bouton 17 — `SYNTH` :** redirige le XY Pad (`Pad X` / `Pad Y`, CC 106 / 107) vers `Macro X` / `Macro Y`.
  * **Bouton 18 — `FX` :** redirige le XY Pad vers `FX X` / `FX Y`.
  * **Bouton 19 — `COMBI` :** redirige le XY Pad vers `Combi X` / `Combi Y`.
  * **Bouton 20 — `PERF` :** redirige le XY Pad vers `Perf X` / `Perf Y`.
* **Retour couleur par mode :** chaque mode allume sa LED dédiée et éteint les autres lors de l'appel à `setMode(...)`.
* **Anti-jitter (`XY_THRESHOLD`) :** filtrage des micro-variations pour éviter les mouvements parasites sur les paramètres cibles.

### 3. Fichier `.remotemap`
* Associe les contrôles déclarés dans le script Lua (`Button 1`–`Button 20`, faders, potentiomètres, XY Pad, etc.) aux paramètres des appareils Reason.
* Permet de réutiliser rapidement les assignations d'un morceau ou d'un appareil à l'autre, et d'ajuster les cibles sans modifier le cœur du script Lua.

---

## Comportements à connaître dans Reason

* **Différences selon les appareils du rack :** certains modules (comme **Thor**, **Combinator** ou **SubTractor**) transmettent bien leurs mises à jour d'état même lorsque le rack est masqué ou lors d'un changement de piste sélectionnée. D'autres modules (comme **Dr. Octo Rex** ou **Redrum**) peuvent nécessiter que le rack soit visible ou que la piste soit active pour que `remote_set_state` reflète immédiatement les changements.
* **Séparation des rôles des boutons :** les boutons **1 à 16** sont destinés au suivi d'état des paramètres via `LED_BUTTONS`, tandis que les boutons **17 à 20** sont réservés au changement de mode XY.

---

## Installation

1. **Récupérer les fichiers :** place le script `.lua` (`Code25.lua`) et le fichier `.remotemap` associé dans le dossier des surfaces de contrôle personnalisées de **Reason** (selon ton installation et ta version de Reason).
2. **Vérifier le port LED :** contrôle la constante `LED_OUTPUT_PORT` dans le script (`2` par défaut) selon la configuration MIDI de ton interface / de ton **M-Audio Code 25** (vérifiable avec un moniteur MIDI comme **MIDI-OX** ou **SendSX**).
3. **Charger dans Reason :** ouvre **Reason**, recharge les surfaces de contrôle (ou redémarre Reason) et sélectionne la surface **M-Audio Code 25**.

---

## Personnalisation et extension

* **Ajouter ou modifier un bouton suivi par LED (1 à 16) :**
  1. Ajoute `output="value"` sur l'item correspondant dans `remote_init()`.
  2. Ajoute ou mets à jour l'entrée dans `LED_BUTTONS` avec ses adresses `OFF` / `ON` et les couleurs souhaitées (`COLOR_OFF`, `COLOR_GREEN`, `COLOR_CYAN`, `COLOR_BLUE`, `COLOR_MAGENTA`, `COLOR_RED`, `COLOR_YELLOW`, `COLOR_WHITE`).
* **Adapter les assignations :** édite le fichier `.remotemap` (après sauvegarde) pour pointer vers les paramètres de tes instruments ou effets favoris.
