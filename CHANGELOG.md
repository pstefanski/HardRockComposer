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

## Commit #0024

### Added

- Nouveau module `MidiWriter`.
- Nouveau module `MidiTracks`.
- Création d'items MIDI depuis les patterns.
- Insertion des notes MIDI dans REAPER.
- Conversion des positions de notes en PPQ.

### Changed

- `Core/Reaper.lua` expose désormais les opérations MIDI :
  - création d'items MIDI ;
  - récupération du Take actif ;
  - insertion de notes MIDI ;
  - mise à jour de l'arrangement.

### Notes

Cette première implémentation génère un seul pattern MIDI de test.

Le positionnement temporel basé sur le tempo et la structure du morceau sera traité dans un commit ultérieur.

## Commit #0025 — Musical Timing & Arrangement

### Added

- Ajout de `Core/Timing.lua`.
- Ajout de `Core/Arrangement.lua`.
- Ajout de `Data/SongSettings.lua`.
- Gestion du tempo du projet.
- Introduction du Quarter Note (QN) comme unité de référence musicale.
- Conversion des mesures en positions musicales (QN).
- Conversion QN → temps projet.
- Conversion QN → PPQ pour l'écriture MIDI.
- Répétition automatique des patterns MIDI sur la durée d'une section.
- Génération automatique des items MIDI à partir de `context.song`.

### Changed

- Le moteur d'arrangement ne travaille plus avec des durées arbitraires en secondes.
- `MidiWriter` utilise désormais les positions musicales du projet pour positionner les notes MIDI.
- `CreateNewMIDIItemInProj()` est utilisé en mode QN.
- Les notes MIDI sont converties en PPQ via les fonctions natives de REAPER.
- Les markers utilisent désormais `Timing.BarToQN()` puis `Reaper.QNToTime()`.
- Les regions utilisent désormais `Timing.BarToQN()` puis `Reaper.QNToTime()`.
- `SongSettings` est transmis aux stages `Markers`, `Regions` et `Arrangement`.

### Fixed

- Correction du décalage entre les sections musicales et les markers/regions REAPER.
- Correction de la conversion `bar → time` qui ne tenait pas compte des 4 beats par mesure.
- Correction du désalignement entre les items MIDI et les sections du morceau.
- Les markers, regions et événements MIDI utilisent désormais la même référence temporelle musicale.

### Architecture

Le moteur utilise désormais une référence temporelle commune :

    Bar
      ↓
    Timing
      ↓
    QN
      ├──→ REAPER Time → Markers / Regions / Items
      │
      └──→ MIDI PPQ → Notes MIDI

### Notes

Le projet utilise actuellement :

- Tempo : 140 BPM
- Signature : 4/4
- 4 QN par mesure

Les variations de tempo et de signature rythmique ne sont pas encore prises en charge.

### Validation

Le système a été vérifié sur :

- Verse 1 : QN 32 → 96
- Chorus 1 : QN 96 → 128
- Verse 2 : QN 128 → 192
- Chorus 2 : QN 192 → 224

Les items MIDI, markers, regions et notes MIDI sont désormais synchronisés avec les frontières des sections.

## Commit #0026 — Drum Fills & Transitions

### Added

- Introduction des fills de batterie.
- Support du champ `fill` dans les sections musicales.
- Ajout de `MidiWriter.WritePatternAtBar()`.
- Ajout du pattern `fill_basic`.

### Changed

- Une section possédant un fill utilise son pattern principal sur toutes
  ses mesures sauf la dernière.
- La dernière mesure est remplacée par le pattern de fill.
- Les fills sont positionnés en utilisant le système temporel QN.

### Validation

- Verse 1 : 15 mesures de groove + 1 mesure de fill.
- Verse 2 : 15 mesures de groove + 1 mesure de fill.
- Transition vers la section suivante sans trou ni chevauchement.

### Architecture

Les fills sont déclarés dans `SongStructure.lua` et non codés en dur
dans le moteur d'arrangement.
## Commit #0027 — Drum Pattern Variations

### Added

- Ajout du pattern `verse_basic_alt`.
- Support des variations de patterns batterie.
- Possibilité de définir un pattern `primary` et une `variation`.
- Sélection déterministe des variations.
- Variation automatique toutes les 4 mesures.

### Changed

- L'Arrangement génère désormais les patterns mesure par mesure
  lorsqu'une variation est définie.
- Le pattern principal reste utilisé par défaut.
- La dernière mesure reste réservée au fill lorsqu'un fill est défini.

### Architecture

Une section peut maintenant définir :

    patterns = {
        drums = {
            primary = "verse_basic",
            variation = "verse_basic_alt"
        }
    }

Le moteur sélectionne ensuite le pattern approprié pour chaque mesure.

### Notes

La sélection des variations est actuellement déterministe.

Aucune randomisation ou humanisation MIDI n'est introduite dans ce commit.

## Commit #0028 — MIDI Track Targets

### Changed

- Le moteur d'arrangement MIDI n'utilise plus une piste `Drums MIDI`
  créée dynamiquement.
- Les événements MIDI batterie sont désormais générés directement sur
  la piste `EZ midi` existante.
- `Arrangement` utilise désormais `context.registry.tracks.ez_midi`.

### Removed

- Création dynamique de la piste `Drums MIDI` par `Arrangement`.

### Architecture

Le moteur MIDI cible désormais les pistes instrument existantes :

    Track Registry
          │
          └── ez_midi
                │
                ▼
           MIDI Writer
                │
                ▼
             EZdrummer

### Notes

`Core/MidiTracks.lua` est conservé temporairement jusqu'à vérification
qu'il n'est plus utilisé par aucun autre module.

Le comportement musical et le timing du Commit #0027 restent inchangés.

## Commit #0029 — Colored Arrangement Regions

### Added

- Ajout d'une palette dédiée aux régions dans `ColorsPalette.lua`.
- Support d'une couleur logique sur les sections musicales.
- Ajout de couleurs aux régions REAPER.
- Validation des références de couleurs inconnues.

### Changed

- `Song.lua` conserve désormais la référence de couleur des sections.
- `Regions.lua` récupère les couleurs depuis `ColorsPalette.regions`.
- `Reaper.AddRegion()` supporte désormais une couleur.
- Utilisation de `AddProjectMarker2()` pour créer les régions colorées.

### Architecture

Les sections référencent une couleur logique :

    color = "verse"

La couleur RGB réelle est centralisée dans :

    ColorsPalette.regions

Le moteur des régions traduit ensuite cette référence en couleur
REAPER.

### Notes

Les couleurs ne sont jamais définies directement dans `SongStructure.lua`.

La palette reste centralisée dans `ColorsPalette.lua`.

Le timing et la génération MIDI du Commit #0028 restent inchangés.

## Commit #0030 — MIDI Humanization

### Added

- Ajout du module `Core/Humanizer.lua`.
- Ajout d'un système d'humanisation MIDI déterministe.
- Variation contrôlée des vélocités des notes.
- Variation contrôlée du timing des notes.
- Ajout d'une seed permettant de reproduire exactement une génération.
- Ajout des paramètres d'humanisation dans `SongSettings.lua`.

### Changed

- `MidiWriter.WritePattern()` délègue désormais l'écriture de chaque
  répétition à `MidiWriter.WritePatternAtBar()`.
- `MidiWriter.WritePatternAtBar()` applique l'humanisation aux notes
  lorsqu'elle est activée.
- `Arrangement.lua` initialise le générateur déterministe une seule fois
  au début de la génération.
- Les patterns principaux et les fills utilisent désormais la même logique
  d'humanisation.

### Preserved

- Les frontières des sections restent inchangées.
- Les positions des Media Items ne sont pas humanisées.
- Les positions structurelles des patterns restent déterministes.
- Le système de timing QN introduit au Commit #0025 reste inchangé.
- Le système de variations et de fills du Commit #0026/#0027 reste inchangé.

### Configuration

Les paramètres sont définis dans `SongSettings.lua` :

    humanization = {
        enabled = true,
        seed = 42,
        velocity = 8,
        timing = 8
    }

### Reproducibility

Une même seed produit exactement la même génération MIDI.

Une seed différente produit une interprétation différente.

### Notes

L'humanisation est actuellement globale à l'arrangement.

Les profils d'humanisation spécifiques au kick, snare, hi-hat, toms et fills
pourront être ajoutés ultérieurement.fiques au kick, snare, hi-hat et aux fills
seront traités ultérieurement.

## Commit #0031 — Drum Dynamics

### Added

- Ajout de la notion d'énergie aux sections musicales.
- Ajout du module `Core/Dynamics.lua`.
- Contrôle de la vélocité MIDI en fonction de l'énergie de la section.

### Changed

- `Song.lua` conserve désormais le niveau d'énergie de chaque section.
- `Arrangement.lua` récupère l'énergie de chaque section pendant la génération.
- `MidiWriter` applique la dynamique avant l'humanisation.
- Les patterns principaux et les fills utilisent l'énergie de leur section.

### Architecture

Le traitement MIDI suit désormais :

    Pattern
       ↓
    Dynamics
       ↓
    Humanization
       ↓
    MIDI

L'énergie représente l'intention musicale de la section, tandis que
l'humanisation apporte les variations d'interprétation.

### Validation

- Les sections peuvent définir leur propre niveau d'énergie.
- Une énergie faible produit une vélocité plus contenue.
- Une énergie élevée conserve davantage la vélocité originale.
- L'humanisation reste appliquée après la dynamique.
- Les frontières des sections et le timing QN restent inchangés.

### Notes

L'énergie contrôle actuellement uniquement la vélocité.

La densité des patterns, les cymbales, les accents et les transitions
pourront exploiter cette information dans les commits suivants.

## Commit #0032 — Advanced Drum Transitions

### Added

- Nouveau module `Core/Transitions.lua`.
- Support du champ `transition` sur les sections musicales.
- Transition `big`, qui sélectionne le fill `fill_big`.
- Pattern `fill_big` et propriété `transitionBeats` sur les fills.
- `MidiWriter.WritePatternUntilBeat()` et `MidiWriter.WritePatternBetweenBeats()`.

### Changed

- Une transition appartient à la section que l'on quitte.
- La dernière mesure conserve le groove jusqu'au début de la transition.
- Le fill est écrit uniquement dans sa fenêtre musicale de transition.
- Les fills d'un temps utilisent la dernière pulsation de leur pattern, sans
  déplacer le pattern complet.
- La dynamique est appliquée avant l'humanisation pour tous les chemins
  d'écriture MIDI.

### Validation

- Verse 1 → Chorus 1 : groove de QN 92 à 95, puis fill de QN 95 à 96.
- Verse 2 → Chorus 2 : groove de QN 188 à 191, puis fill de QN 191 à 192.
- Les frontières QN des sections et des items MIDI restent inchangées.

### Notes

`transitionBeats` prépare l'ajout de fills de plusieurs temps.

## Commit #0033 — EZdrummer Multi-Output Routing

### Added

- Déclaration de `EZdrummer 3 (32 out)` sur la piste `EZD MIDI`.
- Configuration de la piste instrument en 32 canaux.
- Mapping explicite des sorties du VST vers les canaux de la piste.
- Sends stéréo dédiés vers Kick, Snare, HiHat, Toms, Overheads et Room.

### Changed

- Les plugins sont désormais chargés avant la génération MIDI.
- Une erreur explicite est levée lorsqu'un plugin ne peut pas être chargé.
- Le registre des plugins conserve le nom réellement chargé par REAPER.
- Les déclarations de plugins et leurs identifiants sont validés.
- La sortie principale de `EZD MIDI` est désactivée pour éviter le doublage
  du signal envoyé aux pistes de batterie.

### Validation

- EZdrummer se charge sur `EZD MIDI`.
- Les huit sends de sorties batterie sont créés et validés dans REAPER.
- Le routage multi-sorties fonctionne avec le preset de mixeur EZdrummer
  correspondant aux paires de sorties déclarées.
