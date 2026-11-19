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
├── UI/
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
- DrumKit (carte MIDI d'EZdrummer 3 : articulations et parties du kit)
- Patterns/MidiNotes (ancien nom de la carte, gardé pour les styles)

---

## Styles

Un style décrit un morceau : un dossier par style dans `Styles/`, déclaré
dans `Styles/Index.lua`.

```
Styles/HardRock/
├── SongSettings.lua    tempo, signature, swing, humanisation, seeds
├── SongStructure.lua   sections, énergie, couleurs, patterns
├── Drums.lua           grooves générés et patterns de batterie écrits à la main
└── TrackLayout.lua     facultatif, remplace Data/TrackLayout.lua
```

Le style généré est choisi dans `Config.Style`. `Core/StyleLoader.lua` le
charge et le transmet au Builder ; aucun module ne fait de `require` direct
sur les données d'un style.

Les positions sont en doubles croches depuis le début de la mesure, quelle
que soit la signature : une mesure en 12/8 va de 0 à 23.

### Grooves générés

Une section joue de préférence un groove généré :

```lua
patterns = { drums = { groove = "verse" } }
```

Le groove est décrit dans `Drums.grooves` par des règles, que
`Core/DrumGroove.lua` transforme en une phrase de 1, 2 ou 4 mesures :

```lua
verse = {
    phrase = 4,
    pulse = {                                  -- cymbale de tempo
        voice = "closed_hat", every = 2, velocity = 78, accent = 98,
        open = { voice = "open_hat", positions = {14}, chance = 0.4 }
    },
    kick = { positions = {0, 8}, velocity = 112,
             options = { {10, 0.5, 96}, {6, 0.25} } },   -- { position, chance [, vélocité] }
    snare = { positions = {4, 12}, velocity = 114, rimshot = 0.3 },
    ghosts = { positions = {7, 15}, chance = 0.35, velocity = 34, max = 2 },
    extras = { { voice = "high_tom", position = 7, chance = 0.5, velocity = 92 } },
    opening = { voice = "crash", velocity = 122 }   -- première mesure de la section
}
```

La phrase suit une forme question-réponse (A, réponse, A, fin) : la réponse
change une grosse caisse facultative et peut ouvrir le charley, la fin de
phrase change une autre grosse caisse et ouvre toujours le charley. Les
tirages ne dépendent que de `drum_seed` et du nom du groove : deux sections
qui utilisent le même groove jouent la même phrase. Les voix sont les
articulations de `Data/DrumKit.lua`.

Les patterns écrits à la main restent possibles (`primary`, `variation`,
`opening`), avec le vocabulaire de `Core/PatternBuilder.lua` ; la variation
joue alors toutes les 4 mesures. Les fills, les fins et les stop-time
utilisent encore des patterns écrits à la main.

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
    drum_seed = 1,           -- tirage des grooves générés

    humanization = {
        enabled = true, seed = 123, velocity = 8, timing = 8,
        -- facultatif : placement moyen de chaque partie du kit, en ticks
        -- (960 par noire) ; positif = en arrière du temps
        feel = { kick = 0, snare = 8, hats = -4, toms = 4, cymbals = 0 }
    }
}
```

Avec `feel`, l'humanisation du timing se centre sur ce placement (la
plupart des coups restent proches) et les ghost notes varient moins en
vélocité. Les parties du kit sont `kick`, `snare`, `hats`, `toms`,
`cymbals` et `percussion`.

### Sections facultatives

Une section avec `chance` (entre 0 et 1) est facultative. Elle est gardée ou
retirée par un tirage déterministe basé sur `structure_seed` : le même seed
donne toujours le même morceau, un autre seed donne une autre variante.
Au moins une section doit être obligatoire (sans `chance`).

### Accords et basse

Une section peut déclarer sa grille :

```lua
chords = { "E5", "D5", "A5", "E5" },   -- répétée jusqu'à la fin de la section
chord_bars = 1                          -- mesures par accord (0,5 = deux par mesure)
```

Symboles acceptés : fondamentale (A à G, avec # ou b), qualité facultative
(`5`, `m`, `7`, `m7`, `maj7`, `sus4`, `dim`…) et basse facultative
(`D/F#`).

La grille sert à deux choses :

- la piste **Chords** affiche un item texte par changement d'accord ;
- la piste **Bass MIDI** reçoit une ligne de basse si le style déclare
  `bass` dans `SongSettings` :

```lua
bass = {
    mode = "kick",     -- kick : fondamentale sur chaque coup de grosse caisse
                       -- eighths : fondamentale en croches
                       -- boogie : fondamentale, quinte, sixte, quinte en shuffle
    velocity = 100,
    legato = 0.9,      -- longueur des notes, part de l'écart avec la suivante
    lowest_note = 40   -- facultatif : note la plus grave du registre (E2 par défaut)
}
```

La basse joue dans l'octave qui commence à `lowest_note`. Le défaut E2 (40)
correspond aux instruments qui, comme EZbass, jouent la corde de mi grave une
octave au-dessus du son réel, comme en notation. Pour un instrument qui
attend la hauteur réelle, utiliser `lowest_note = 28` (E1).

En mode `kick`, la basse lit le plan de batterie de la section
(`Arrangement.DrumPlan`) : elle suit les variations et les fills.

### Décompte

`count_in = { bars = 1 }` décale le morceau d'une mesure et écrit un
décompte au side stick (un coup par temps ressenti : noire pointée en 12/8),
avec un marqueur « Count-in ».

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
- un preset est cherché d'abord dans REAPER, puis dans `Presets/` (état du
  plugin exporté par `ExportPresets.lua`, appliqué seulement au même plugin
  dans le même format) ;
- un preset introuvable n'arrête pas la génération : le plugin garde ses
  réglages par défaut ;
- un plugin non optionnel introuvable arrête la génération.

Rien n'est affiché pendant le chargement. En fin de génération, la console
affiche un rapport d'une ligne par catégorie : plugins chargés, remplacés,
ignorés, presets chargés, lus dans `Presets/` ou introuvables.

---

# Automation

Une piste peut suivre l'énergie des sections :

```lua
automation = {
    volume = { low = -3, high = 0 }    -- dB à l'énergie 0 et à l'énergie 1
}
```

Le décalage s'ajoute au volume de la piste (`properties.volume`) et est écrit
dans l'enveloppe de volume, un point carré au début de chaque section.

---

# Interface

`Main.lua` ouvre la fenêtre si ReaImGui est installé, sinon il génère
directement.

```
UI/App.lua      boucle ReaImGui (defer), API ReaImGui 0.10
UI/Window.lua   dessin uniquement : reçoit ImGui en paramètre
      │
      ├── Session        choix de l'utilisateur, appliqués à une copie du style
      ├── Generator      génération (aussi utilisée sans fenêtre)
      └── PluginScanner  état estimé des plugins installés
```

La fenêtre ne contient aucune logique métier : tout passe par `Session`,
`Generator` et `PluginScanner`, testés sans REAPER. Les tests font tourner la
fenêtre avec un faux ReaImGui (`Tests/FakeImGui.lua`) qui n'expose que les
fonctions utilisées.

Les choix sont enregistrés par style dans l'ExtState de REAPER
(`HardRockComposer/session.<Style>`), avec le dernier style utilisé.

La tonalité du style est déclarée dans `SongSettings.key` ; choisir une
autre tonalité transpose tous les accords (basse et piste Chords).

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
| DrumGroove | Génération des grooves de batterie à partir des règles d'un style |
| Random | Générateur pseudo-aléatoire déterministe |
| Arrangement | Batterie MIDI, plan de batterie, décompte |
| Harmony | Symboles d'accords, grille d'une section |
| Bass | Ligne de basse MIDI |
| ChordGuide | Piste de grille d'accords |
| Automation | Enveloppes pilotées par l'énergie |
| PresetStore | Lecture et écriture des états de plugins dans `Presets/` |
| PresetExport | Export des presets HRC chargés |
| Session | Choix de l'utilisateur, application au style, sauvegarde |
| Serialize | Lecture et écriture de données Lua sans code |
| Generator | Génération à partir d'un style et des choix |
| PluginScanner | État estimé des plugins installés |
| UI/Window | Fenêtre ReaImGui |
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

Patterns et grooves → Arrangement (batterie, décompte)

↓

Bass → ChordGuide → Automation
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