# HardRock Composer Architecture

Ce document décrit les principes fondamentaux de HardRock Composer.

Il constitue la référence pour toute évolution du projet.

Les règles décrites ici sont considérées comme stables.

---

# Philosophie

HardRock Composer est un moteur de génération de projets REAPER.

Le moteur est **Data Driven**.

Les données décrivent **ce qui doit être construit**.

Le code décrit **comment le construire**.

---

# Structure du projet

```
HardRockComposer/

├── Core/
│
├── Data/
│
├── Styles/
│
├── Tests/
│
├── Main.lua
├── Config.lua
├── Version.lua
│
├── CHANGELOG.md
├── ROADMAP.md
└── ARCHITECTURE.md
```

## Core

Le dossier `Core` contient uniquement la logique métier.

Exemples :

- Builder
- Tracks
- Routing
- Colors
- Properties
- Plugins

Chaque module possède une responsabilité unique.

---

## Data

Le dossier `Data` contient uniquement des données déclaratives.

Aucune logique ne doit être présente dans ce dossier.

Exemples :

- TrackLayout (commun à tous les styles)
- ColorsPalette
- Patterns/MidiNotes (mapping des notes EZdrummer)

---

## Styles

Un style décrit un morceau : un dossier par style dans `Styles/`, déclaré
dans `Styles/Index.lua`.

```
Styles/HardRock/
├── SongSettings.lua    tempo, signature, swing, humanisation, seeds
├── SongStructure.lua   sections, énergie, couleurs, patterns
├── Drums.lua           bibliothèque de patterns de batterie
└── TrackLayout.lua     facultatif, remplace Data/TrackLayout.lua
```

Le style généré est choisi dans `Config.Style`. `Core/StyleLoader.lua` le
charge et le transmet au Builder ; aucun module ne fait de `require` direct
sur les données d'un style.

Les patterns sont décrits avec le vocabulaire de `Core/PatternBuilder.lua`.
Les positions sont en doubles croches depuis le début de la mesure, quelle
que soit la signature : une mesure en 12/8 va de 0 à 23.

### Réglages musicaux

```lua
{
    tempo = 105,             -- en noires par minute (convention REAPER)
    beats_per_bar = 12,
    beat_unit = 8,           -- 2, 4, 8 ou 16

    swing = {                -- facultatif
        amount = 0.3,        -- 0 = droit, 1 = shuffle complet (triolet)
        subdivision = 8      -- 8 : contretemps de croche, 16 : doubles croches impaires
    },

    structure_seed = 1,      -- tirage des sections facultatives

    humanization = { enabled = true, seed = 123, velocity = 8, timing = 8 }
}
```

### Sections facultatives

Une section avec `chance` (entre 0 et 1) est facultative. Elle est gardée ou
retirée par un tirage déterministe basé sur `structure_seed` : le même seed
donne toujours le même morceau, un autre seed donne une autre variante.
Au moins une section doit être obligatoire (sans `chance`).

### Transitions

Un fill (`fill = "…"`) remplace la fin de la dernière mesure d'une section.
Sa durée `transitionBeats` est exprimée en noires (1,5 = une noire pointée en
12/8). Une section `transition = "big"` utilise le pattern `fill_big` du
style.

---

# Architecture générale

Le moteur suit toujours le même cycle.

```
TrackLayout
      │
      ▼
 Builder
      │
      ▼
 BuildContext
      │
      ├── Tracks
      ├── Routing
      ├── Properties
      ├── Plugins
      └── ...
```

Chaque module travaille sur le même `BuildContext`.

---

# BuildContext

Le BuildContext contient les références créées pendant la génération.

Exemple :

```lua
context = {

    groups = {},

    tracks = {},

    registry = {

        groups = {},

        tracks = {}

    }

}
```

Les listes (`groups`, `tracks`) conservent l'ordre de création.

Le registre permet un accès immédiat par identifiant.

Exemple :

```lua
context.registry.tracks.kick

context.registry.groups.drums
```

---

# Identifiants

Toute entité persistante possède un identifiant unique.

Le moteur ne dépend jamais des noms affichés.

Le champ `id` est utilisé par le code.

Le champ `name` est utilisé uniquement pour l'affichage.

Exemples :

```
kick
snare
drum_bus
bass
lead_vocal
```

---

# Structure d'une piste

Une piste possède une structure fixe.

```lua
{

    -- identité

    id = "kick",

    name = "Kick",

    type = "audio",

    role = "closemic",

    color = "drums",

    --------------------------------------------------
    -- Modules
    --------------------------------------------------

    routing = {

        output = "drum_bus"

    },

    properties = {

        volume = -6,

        pan = -0.15,

        mute = false,

        solo = false

    },

    plugins = {

    },

    record = {

    },

    metadata = {

    }

}
```

Les blocs sont optionnels.

Chaque module ne lit que son propre bloc.

---

# Structure d'un groupe

Les groupes représentent uniquement l'organisation visuelle.

```lua
{

    id = "drums",

    name = "DRUMS",

    color = "drums",

    tracks = {

        ...

    }

}
```

---

# Routing

Les dossiers REAPER servent uniquement à organiser le projet.

Ils ne représentent pas des bus audio.

Les bus sont des pistes normales.

Le routage audio est réalisé exclusivement avec des Track Sends.

Exemple :

```
▼ DRUMS

    Kick
    Snare
    OH
    Room

Drum Bus
```

Flux audio :

```
Kick
    │
    ├────────────► Drum Bus

Snare
    │
    ├────────────► Drum Bus
```

Lorsqu'une piste possède un bloc `routing` :

- un Track Send est créé ;
- le Parent Send est désactivé.

---

# Plugins

Un plugin est déclaré dans le bloc `plugins` d'une piste.

```lua
{
    id = "bass_bus_1176",

    -- Candidats essayés dans l'ordre : le premier que REAPER charge l'emporte.
    plugin = {
        "VST3: UADx 1176 Rev A Compressor",     -- hérite de `preset`
        "AU: UADx 1176 Rev A Compressor",       -- hérite de `preset`
        { plugin = "VST: ReaComp (Cockos)" }    -- preset propre (aucun ici)
    },

    preset = "HRC Bass Bus 1176",

    -- Facultatif : si aucun candidat n'est disponible, un warning remplace l'erreur.
    optional = true
}
```

Règles :

- `plugin` peut aussi être un simple nom ;
- un candidat écrit comme un nom hérite du `preset` de la déclaration ;
- un candidat écrit comme une table utilise son propre `preset` : c'est la
  forme à employer pour les plugins de remplacement REAPER ;
- un preset introuvable n'arrête pas la génération : le plugin garde ses
  réglages par défaut et un warning est affiché ;
- un plugin non optionnel introuvable arrête la génération.

En fin de génération, la console affiche un rapport : plugins chargés,
remplacés, absents, et presets manquants.

---

# Wrapper REAPER

Aucun module ne doit appeler directement l'API REAPER.

Toutes les interactions passent par :

```
Core/Reaper.lua
```

Cette règle permet :

- d'isoler l'API REAPER ;
- de simplifier les tests ;
- de limiter les dépendances.

---

# Responsabilités des modules

Chaque module possède une responsabilité unique.

| Module | Responsabilité |
|---------|----------------|
| Builder | Orchestration |
| Validator | Validation des données avant génération |
| Project | Réinitialisation, tempo et signature |
| StyleLoader | Chargement d'un style |
| Song | Disposition des sections, sections facultatives |
| Timing | Conversions mesures / noires, swing |
| PatternBuilder | Vocabulaire de description des patterns |
| Random | Générateur pseudo-aléatoire déterministe |
| Tracks | Création des pistes |
| Colors | Couleurs |
| Routing | Routage audio |
| Properties | Propriétés natives |
| Plugins | Insertion des plugins, remplacements et rapport |
| Logger | Journalisation |
| Reaper | Wrapper API |

---

# Ordre de construction

Le Builder exécute toujours les modules dans un ordre déterministe.

```
Validation des données

↓

Project (reset, marqueurs, tempo, signature)

↓

Tracks → Routing → Properties → Plugins

↓

Song → Markers → Regions

↓

Patterns → Arrangement
```

Chaque étape peut utiliser les résultats des étapes précédentes.

La validation s'exécute avant toute modification du projet : si les données
sont invalides, toutes les erreurs sont listées et le projet courant reste
intact.

L'étape `Project` s'exécute en premier, car toute conversion
mesure → temps dépend de la carte de tempo.

---

# Tests

Les tests s'exécutent hors de REAPER, avec un interpréteur Lua 5.4+ :

```
lua Tests/run.lua
```

`Tests/MockReaper.lua` remplace l'API `reaper` par un état en mémoire.
C'est possible parce qu'aucun module n'appelle l'API directement :
tout passe par `Core/Reaper.lua`.

Toute nouvelle fonctionnalité doit être accompagnée de tests.

---

# Principes de développement

Toute nouvelle fonctionnalité doit respecter les règles suivantes.

## Une responsabilité par module

Un module ne fait qu'une seule chose.

---

## Une fonctionnalité par commit

Chaque commit doit :

- être compilable ;
- être testable ;
- ne pas casser les fonctionnalités existantes.

---

## Pas de recherche par nom

Le moteur utilise exclusivement les identifiants (`id`).

Exemple :

```lua
context.registry.tracks.kick
```

Jamais :

```lua
FindTrackByName("Kick")
```

---

## Data First

Le moteur ne contient jamais de valeurs métier codées en dur.

Toutes les informations proviennent des fichiers présents dans `Data/` et `Styles/`.

---

# Vision

L'objectif est de construire un moteur :

- modulaire ;
- déterministe ;
- maintenable ;
- extensible ;
- indépendant des noms affichés.

La même configuration doit toujours produire exactement le même projet REAPER.