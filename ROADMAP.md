# Feuille de route — HardRock Composer

Ce document décrit le chemin de la v0.5 à la v1.0.

Chaque sprint fait l'objet d'une branche `feat/sprint-N-…` et d'une pull request. Le principe « data-driven » reste la règle (voir [ARCHITECTURE.md](ARCHITECTURE.md)) : la logique va dans `Core/`, les données déclaratives dans `Data/`, puis dans `Styles/` à partir du sprint 7.

Légende : ✅ fait · 🚧 en cours · ⬜ à faire

---

## Déjà livré (sprints 1 à 4)

- Génération des pistes, dossiers, couleurs et propriétés
- Routage par sends (bus, retours FX, sorties multiples)
- Insertion des plugins et presets HRC : EZdrummer 3 (32 sorties), TONEX, UADx, ValhallaDelay
- Structure du morceau, marqueurs et régions colorées
- Moteur MIDI batterie : patterns par section, variations, fills, transitions, dynamique et humanisation déterministe

---

## Sprint 5 — Fondations et portabilité (v0.5) 🚧

Objectif : un socle fiable sur Windows **et** macOS.

- ✅ **Chemins portables** : `Main.lua` utilise le séparateur de la plateforme.
- ✅ **Une seule source pour les réglages musicaux** : `SongSettings` fournit le tempo et la signature. Ils sont appliqués par la nouvelle étape `Project`, qui tourne en premier.
- ✅ **Bugs corrigés en chemin** : l'étape Regions effaçait les marqueurs, et les marqueurs et régions étaient placés avant l'application du tempo final.
- ✅ **Validation des données** : `Core/Validator.lua` contrôle tout avant la moindre modification du projet et liste toutes les erreurs.
- ✅ **Tests hors REAPER** : `lua Tests/run.lua`, avec un mock de l'API `reaper` et un test d'intégration du Builder complet.
- ✅ **Ménage** : `ARCHITECTURE.md` renommé, README à jour, variable inutilisée supprimée.
- ⬜ **Validation manuelle dans REAPER**, sur Windows et sur macOS.

## Sprint 6 — Détection des plugins et mode dégradé (v0.6) ⬜

Objectif : générer un projet utilisable même si un plugin manque.

- ⬜ `Core/PluginScanner.lua` : inventaire des FX installés via `reaper.EnumInstalledFX`, mis en cache dans le `BuildContext`.
- ⬜ **Fallbacks déclaratifs** : `plugin = { "VST3: UADx 1176 Rev A Compressor", "VST: ReaComp (Cockos)" }`. Le premier plugin disponible l'emporte.
- ⬜ `optional = true` : un plugin manquant produit un warning au lieu d'une erreur.
- ⬜ **Presets HRC versionnés** dans `Presets/`, installés via `GetResourcePath()`, avec des paramètres de secours (`TrackFX_SetParam`).
- ⬜ **Rapport de fin de génération** : plugins trouvés, remplacés ou absents.
- ⬜ Le validateur accepte les listes de plugins de remplacement.

## Sprint 7 — Styles (v0.7) ⬜

Objectif : ajouter un style sans modifier `Core/`.

- ⬜ **Un dossier par style** : `Styles/<Style>/` regroupe `SongSettings`, `SongStructure`, `Patterns/Drums` et un éventuel override de `TrackLayout`. Le style actuel y migre sous le nom `HardRock`.
- ⬜ `Core/StyleLoader.lua` : `Builder.Build(style)` remplace les `require` codés en dur.
- ⬜ **Nouveaux styles** : Classic Rock, Blues Rock (12/8, shuffle), Heavy Rock (double pédale), Punk Rock.
- ⬜ **Shuffle, swing et signatures autres que x/4** dans `Timing` et `Humanizer`. Le validateur refuse aujourd'hui `beat_unit ~= 4`.
- ⬜ **Variantes de structure déterministes** tirées d'un seed : pont, double refrain, breakdown.

## Sprint 8 — Moteur musical étendu (v0.8) ⬜

- ⬜ **Basse MIDI** calée sur la grosse caisse et une grille d'accords déclarée par section.
- ⬜ **Guide d'accords** par section, pour les guitaristes.
- ⬜ **Automation pilotée par l'énergie** des sections : volume des bus, envois FX.
- ⬜ **Décompte** (count-in) optionnel avant l'intro.

## Sprint 9 — Interface graphique (v0.9) ⬜

- ⬜ **ReaImGui** via ReaPack, avec repli sur la génération par défaut si l'extension est absente.
- ⬜ **Écran de configuration** : style, tempo, signature, tonalité, seed, sections, état des plugins.
- ⬜ **Persistance** des choix avec `SetExtState`.
- ⬜ **Génération non destructive** dans un nouvel onglet de projet.

## Sprint 10 — Stabilisation et distribution (v1.0) ⬜

- ⬜ **Paquet ReaPack** : `index.xml` et en-tête de métadonnées.
- ⬜ **Documentation** dans `Docs/` : installation, création d'un style, format des données.
- ⬜ **Tests de bout en bout** dans REAPER : pistes, sends, régions, notes MIDI.
- ⬜ **Version 1.0.0** : CHANGELOG consolidé (titres manquants pour les commits #0001 à #0024) et tag git.

---

## Vérification à chaque sprint

- `lua Tests/run.lua` passe.
- `Main.lua` s'exécute dans REAPER sous Windows et macOS : la console affiche « Done. » sans erreur.
- Contrôles manuels : tempo et signature, pistes et couleurs, sends FX, régions alignées sur les sections, notes MIDI sur la grille.
