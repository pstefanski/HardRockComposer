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

## Sprint 6 — Plugins en mode dégradé (v0.6) 🚧

Objectif : générer un projet utilisable même si un plugin manque.

- ✅ **Candidats déclaratifs** : VST3, puis AU, puis plugin REAPER de remplacement. Le premier que REAPER charge l'emporte.
- ✅ `optional = true` : un plugin manquant produit un warning au lieu d'une erreur. Concerne EZdrummer, TONEX, Studer et Ampex.
- ✅ **Preset manquant** : simple warning, le plugin garde ses réglages par défaut.
- ✅ **Rapport de fin de génération** : plugins chargés, remplacés, absents, presets manquants.
- ✅ Le validateur accepte les listes de candidats.
- ⬜ **Presets HRC versionnés** dans `Presets/` et installés via `GetResourcePath()`. Bloqué : les presets n'existent que sur la machine Windows et doivent d'abord en être exportés.
- ⬜ **Validation manuelle dans REAPER**, sur Windows et sur macOS.
- ↪️ **Scanner des plugins installés** (`EnumInstalledFX`) : reporté au sprint 9. C'est le chargement réel par REAPER qui fait foi. Un pré-scan devrait reproduire sa recherche par nom partiel et risquerait de déclarer absent un plugin pourtant chargeable. Le scanner sera utile pour afficher l'état des plugins dans l'interface.

## Sprint 7 — Styles (v0.7) 🚧

Objectif : ajouter un style sans modifier `Core/`.

- ✅ **Un dossier par style** : `Styles/<Style>/` regroupe `SongSettings`, `SongStructure` et `Drums`, avec un `TrackLayout` facultatif. Le style actuel a migré dans `Styles/HardRock/`, avec une génération identique à l'octet près.
- ✅ **Chargement des styles** : `Core/StyleLoader.lua` et `Styles/Index.lua`. Le style est choisi dans `Config.Style`, et `Builder.Build(style)` remplace les `require` codés en dur.
- ✅ **Patterns partagés** : `Core/PatternBuilder.lua` fournit le vocabulaire commun pour décrire les patterns.
- ✅ **Nouveaux styles** : Classic Rock (shuffle léger), Blues Rock (12/8, grille de 12 mesures, stop time), Heavy Rock (galop, double pédale, breakdown), Punk Rock (190 BPM, skank beat).
- ✅ **Signatures autres que x/4** (`Timing.QNPerBar`) et **swing** en croches ou en doubles croches.
- ✅ **Variantes de structure déterministes** : sections facultatives (`chance`) tirées à partir de `structure_seed`.
- ⬜ **Validation à l'oreille dans REAPER**, style par style, avec EZdrummer.

## Sprint 8 — Moteur musical étendu (v0.8) 🚧

- ✅ **Grilles d'accords par section** (`chords`, `chord_bars`), lues par `Core/Harmony.lua`.
- ✅ **Basse MIDI** sur une nouvelle piste Bass MIDI (EZbass, sinon ReaSynth), en trois modes : calée sur la grosse caisse, en croches, ou boogie. Lignes définies pour les cinq styles.
- ✅ **Grille pour les guitaristes** : piste Chords, un item texte par changement d'accord.
- ✅ **Automation pilotée par l'énergie** : Drum Bus, Bass Bus, Guitar Bus et retour Hall. Elle agit sur le niveau du retour, et non sur chaque envoi, pour rester simple à relire.
- ✅ **Décompte** facultatif (`count_in`), désactivé par défaut.
- ⬜ **Validation dans REAPER** : création des enveloppes de volume (action 40406), items texte, écoute des lignes de basse.

## Sprint 9 — Interface graphique (v0.9) ⬜

- ⬜ **ReaImGui** via ReaPack, avec repli sur la génération par défaut si l'extension est absente.
- ⬜ **Écran de configuration** : style, tempo, signature, tonalité, seed, sections.
- ⬜ **État des plugins** : `Core/PluginScanner.lua` (`EnumInstalledFX`), reporté du sprint 6.
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
