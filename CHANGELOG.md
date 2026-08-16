# Changelog

Toutes les évolutions importantes du projet sont documentées ici.

Le projet suit une évolution incrémentale : chaque commit représente un état stable et testable.

---

# [0.1.0-alpha]

## Commit #0001

### Added

- Initialisation du projet HardRock Composer.
- Structure du dépôt.
- Modules de base :
  - Main.lua
  - Config.lua
  - Version.lua
  - Logger.lua
- Configuration du tempo.
- Initialisation des blocs Undo REAPER.
- Premier système de journalisation.

### Notes

Premier bootstrap du projet.

---

## Commit #0002

### Added

- Wrapper REAPER (`Core/Reaper.lua`).
- Builder (`Core/Builder.lua`).
- Module de création des pistes (`Core/Tracks.lua`).
- Premier `TrackLayout`.
- Génération automatique de la structure des pistes.

### Notes

Première génération automatique d'un projet REAPER.

---

## Commit #0003

### Added

- Gestion des dossiers REAPER.
- Support de `I_FOLDERDEPTH`.
- Création automatique des groupes :
  - DRUMS
  - BASS
  - GUITARS
  - VOCALS
  - FX

### Notes

Les pistes sont désormais organisées dans de vrais dossiers REAPER.

---

## Commit #0004

### Added

- Réinitialisation automatique du projet avant génération.
- Suppression de toutes les pistes existantes.
- Nouvelle fonction :

```
Reaper.ResetProject()
```

### Changed

- Le script produit désormais toujours la même structure.

### Notes

Plus aucun doublon après plusieurs exécutions.

---

## Commit #0005

### Changed

Le `TrackLayout` utilise maintenant des objets Lua au lieu de simples chaînes.

### Added

Chaque piste possède désormais :

- name
- type
- role
- color

### Notes

Aucun changement fonctionnel.

Cette évolution prépare les futures fonctionnalités.

---

## Commit #0006

### Added

- Gestion centralisée des couleurs.
- Nouvelle palette (`Data/ColorPalette.lua`).
- Nouveau module (`Core/Colors.lua`).
- Coloration automatique des groupes.
- Coloration automatique des pistes.

### Fixed

- Correction du conflit de modules entre :
  - Core/Colors.lua
  - Data/Colors.lua

Le fichier de données a été renommé :

```
ColorPalette.lua
```

### Notes

Première fonctionnalité exploitant réellement les nouvelles métadonnées.

---

## Commit #0007

### Changed

Les groupes deviennent des objets complets.

Avant :

```
folder = "DRUMS"
```

Après :

```
id = "drums"
name = "DRUMS"
color = "drums"
```

### Added

Les groupes possèdent maintenant :

- id
- name
- color

### Notes

Les dossiers deviennent des entités métier au même titre que les pistes.

---

## Commit #0008

### Changed

Toutes les pistes disposent désormais d'un identifiant stable.

### Added

Nouvelle propriété :

```
id
```

Exemple :

```
{
    id = "kick",
    name = "Kick",
    ...
}
```

### Notes

Le moteur ne dépend plus du nom affiché des pistes.

Cette évolution prépare le futur système de routage.

---

## Commit #0009

### Added

Introduction du BuildContext.

Le Builder retourne maintenant une structure contenant :

- les groupes créés
- les pistes créées
- leurs références REAPER

### Changed

Nouvelle signature :

```
local context = Builder.Build(layout)
```

Le contexte contient :

- data
- track
- group

pour chaque piste créée.

### Notes

Aucun changement visuel.

Cette évolution prépare :

- TrackRegistry
- Routing
- Plugins
- Markers

## Commit #0010

### Added

- Introduction d'un registre (`registry`) dans le `BuildContext`.
- Accès direct aux groupes via leur `id`.
- Accès direct aux pistes via leur `id`.

### Notes

Les listes `groups` et `tracks` sont conservées pour préserver l'ordre de création, tandis que le registre offre un accès instantané par identifiant.

## Commit #0011

### Added

- Nouveau module `Routing`.
- Création automatique des Track Sends.
- Nouveau champ `route_to` dans le `TrackLayout`.

### Notes

Le routage est basé sur les identifiants des pistes (`id`) et le registre (`context.registry`).

Une seule destination est supportée dans cette première version.

## Commit #0012

### Fixed

- Désactivation automatique du Parent Send pour les pistes utilisant `route_to`.

### Added

- Nouveau document `ARCHITECTURE.md`.
- Formalisation des règles fondamentales du moteur.

### Notes

Les dossiers REAPER sont désormais considérés comme des éléments d'organisation uniquement.

Le routage audio est réalisé exclusivement via des Track Sends.

## Commit #0013

### Added

- Nouveau module `Properties`.
- Application des propriétés natives des pistes :
  - volume
  - pan
  - mute
  - solo

### Notes

Les propriétés sont définies directement dans le `TrackLayout` et appliquées après la création des pistes et du routage.

## Commit #0014

### Changed

- Réorganisation de la définition des pistes dans `TrackLayout`.
- Introduction des blocs `routing` et `properties`.

### Notes

Les données sont désormais regroupées par responsabilité, ce qui prépare l'ajout des futurs blocs (`plugins`, `record`, etc.) sans surcharger la racine des pistes.

## Commit #0015

### Changed

- Le `Builder` exécute désormais une liste de stages.
- `Tracks.Create()` est renommé en `Tracks.Apply()` pour harmoniser l'API interne.

### Notes

Cette évolution permet d'ajouter de nouveaux modules de génération sans modifier la logique du `Builder`.

## Commit #0016

### Added

- Nouveau module `Plugins`.
- Insertion automatique des plugins définis dans `TrackLayout`.
- Nouveau wrapper `Reaper.InsertFX()`.

### Notes

Les plugins sont insérés dans l'ordre de déclaration.
Cette première version ne gère pas encore les presets ni les erreurs de plugin introuvable.

## Commit #0018

### Added

- Chargement automatique des presets de plugins.
- Chaque instance de plugin peut désormais référencer un preset.
- Nouveau wrapper `Reaper.LoadPreset()`.

### Changed

- Le moteur de plugins applique désormais les presets immédiatement après l'insertion du plugin.
- La structure des plugins dans le `TrackLayout` est enrichie.

Avant :

```lua
plugins = {

    {
        id = "eq",
        plugin = "VST3: ReaEQ (Cockos)"
    }

}
```

Après :

```lua
plugins = {

    {
        id = "eq",
        plugin = "VST3: ReaEQ (Cockos)",
        preset = "Rock EQ"
    }

}
```

### Notes

Les presets sont chargés uniquement lorsqu'ils sont définis.

Cette évolution prépare les prochaines fonctionnalités :

- paramètres des plugins ;
- bypass ;
- activation/désactivation ;
- automation ;
- validation des presets.

## Commit #0019

### Added

- Nouveau module `Song`.
- Nouveau fichier `SongStructure`.
- Calcul automatique des positions des sections du morceau.
- Nouveau registre `context.registry.song`.

### Notes

Cette première version ne crée pas encore de marqueurs ou de régions dans REAPER.

Les informations de structure sont désormais disponibles dans le `BuildContext` pour les futurs modules :
- Markers
- Regions
- MIDI
- Automation

## Commit #0020

### Added

- Nouveau module `Markers`.
- Génération automatique des marqueurs REAPER à partir de la structure du morceau.
- Nouveaux wrappers :
  - `ClearMarkers()`
  - `AddMarker()`
  - `BarToTime()`

### Notes

Les marqueurs sont recréés à chaque génération afin d'éviter les doublons.

Cette évolution prépare le futur module de régions REAPER.

## Commit #0021

### Added

- Nouveau module `Regions`.
- Génération automatique des régions REAPER à partir de la structure du morceau.
- Nouveau wrapper `AddRegion()`.

### Notes

Les régions sont alignées sur les marqueurs et couvrent exactement les sections définies dans `SongStructure`.

Cette évolution prépare les futurs modules de génération MIDI et d'arrangement.

## Commit #0022

### Added

- Introduction du système de patterns.
- Nouveau module `Core/Patterns.lua`.
- Nouveau dossier `Data/Patterns/`.
- Première bibliothèque de patterns batterie.
- Registre `context.registry.patterns`.
- Association de patterns aux sections du morceau.

### Notes

Les patterns sont actuellement déclaratifs et ne contiennent pas encore de données MIDI.

Cette étape prépare le futur moteur de génération MIDI.

## Commit #0023

### Added

- Introduction du modèle MIDI.
- Nouveau module `Core/Midi.lua`.
- Nouvelle table `Data/Patterns/MidiNotes.lua`.
- Ajout de notes MIDI aux patterns batterie.
- Validation des notes et patterns MIDI.

### Changed

- Les patterns batterie contiennent désormais :
  - une résolution ;
  - une durée en mesures ;
  - des notes ;
  - pitch ;
  - position ;
  - longueur ;
  - vélocité.

### Notes

Aucun item MIDI REAPER n'est encore créé.

Ce commit établit le modèle de données utilisé par le futur moteur MIDI.