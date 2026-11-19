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

## Sprint 5 — Fondations et portabilité (v0.5) ✅

Objectif : un socle fiable sur Windows **et** macOS.

- ✅ **Chemins portables** : `Main.lua` utilise le séparateur de la plateforme.
- ✅ **Une seule source pour les réglages musicaux** : `SongSettings` fournit le tempo et la signature. Ils sont appliqués par la nouvelle étape `Project`, qui tourne en premier.
- ✅ **Bugs corrigés en chemin** : l'étape Regions effaçait les marqueurs, et les marqueurs et régions étaient placés avant l'application du tempo final.
- ✅ **Validation des données** : `Core/Validator.lua` contrôle tout avant la moindre modification du projet et liste toutes les erreurs.
- ✅ **Tests hors REAPER** : `lua Tests/run.lua`, avec un mock de l'API `reaper` et un test d'intégration du Builder complet.
- ✅ **Ménage** : `ARCHITECTURE.md` renommé, README à jour, variable inutilisée supprimée.
- ✅ **Validation manuelle dans REAPER**, sur Windows et sur macOS.

## Sprint 6 — Plugins en mode dégradé (v0.6) ✅

Objectif : générer un projet utilisable même si un plugin manque.

- ✅ **Candidats déclaratifs** : VST3, puis AU, puis plugin REAPER de remplacement. Le premier que REAPER charge l'emporte.
- ✅ `optional = true` : un plugin manquant produit un warning au lieu d'une erreur. Concerne EZdrummer, TONEX, Studer et Ampex.
- ✅ **Preset manquant** : simple warning, le plugin garde ses réglages par défaut.
- ✅ **Rapport de fin de génération** : plugins chargés, remplacés, absents, presets manquants.
- ✅ Le validateur accepte les listes de candidats.
- ✅ **Presets HRC versionnés** dans `Presets/` : `ExportPresets.lua` (lancé sur Windows) enregistre l'état de chaque plugin, et la génération l'applique quand REAPER ne connaît pas le preset. Validé sur macOS : 24 presets sur 24 rechargés.
- ✅ **Console** : rapport final d'une ligne par catégorie, plus aucun warning pendant le chargement.
- ✅ **Validation manuelle dans REAPER** : Windows (export des presets) et macOS (25 plugins chargés, ValhallaDelay remplacé par ReaDelay).
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

## Sprint 9 — Interface graphique (v0.9) 🚧

- ✅ **ReaImGui** (API 0.10, installé via ReaPack). Sans l'extension, `Main.lua` génère directement avec les derniers choix.
- ✅ **Onglet Song** : style, tempo, tonalité (accords transposés), seed de structure, décompte, mode de basse, swing. La signature est affichée mais pas modifiable, car les patterns d'un style sont écrits pour sa signature.
- ✅ **Onglet Sections** : nom, nombre de mesures, énergie, jeu (toujours / jamais / selon le seed), réordonnancement, duplication, suppression, durée estimée.
- ✅ **Onglet Plugins** : `Core/PluginScanner.lua` (`EnumInstalledFX`) estime le candidat chargé pour chaque plugin et indique la présence du preset dans `Presets/`.
- ✅ **Persistance** des choix par style avec `SetExtState`.
- ✅ **Génération non destructive** dans un nouvel onglet de projet (action 40859).
- ⬜ **Validation dans REAPER**, sur macOS et sur Windows.

## Sprint 10 — Tests automatiques 🚧

- ✅ **GitHub Actions** (`.github/workflows/tests.yml`) : à chaque push sur `main` et à chaque pull request, vérification de la syntaxe de tous les scripts puis `lua Tests/run.lua`, avec Lua 5.4 (celle de REAPER) et Lua 5.5.
- ⬜ **Protection de `main`** : exiger le passage des tests avant la fusion d'une PR (réglage du dépôt GitHub).

## Sprint 11 — Batterie générative : les grooves (v0.11) ✅

Constat : un style déclare un pattern d'une mesure rejoué à l'identique, avec une variante toutes les 4 mesures. On n'entend ni ghost notes, ni ouvertures de charley, ni accents, et le kit se limite à 12 notes.

- ✅ **Kit EZdrummer complet** (`Data/DrumKit.lua`) : articulations du charley, quatre crashes et leurs coups étouffés, china, splash, cloche de ride, rimshots, d'après la MIDI map d'EZdrummer 3.
- ✅ **Grammaire de groove par style** : pour chaque type de section, positions de grosse caisse (fixes et probables), backbeat, ghost notes, cymbale de tempo et débit, accents, ouvertures de charley, longueur de phrase.
- ✅ **`Core/DrumGroove.lua`** : génère une phrase de 2 ou 4 mesures (cellule, réponse, mutation de fin de phrase), déterministe avec `drum_seed`. Deux sections du même type partagent le même groove.
- ✅ **Plan de batterie par phrase** : `drums = { groove = "verse" }` à côté des patterns écrits à la main, qui restent pris en charge.
- ✅ **Placement par fût** : aléa centré et décalage moyen par fût (caisse claire en arrière, charley serré).
- ✅ **Migration** des 5 styles, seed de batterie dans la fenêtre, contrôles du validateur.
- ✅ **Écoute dans REAPER** : articulations et rendu des grooves dans EZdrummer.

## Sprint 12 — Batterie générative : fills et transitions (v0.12) 🚧

- ✅ **`Core/DrumFill.lua`** : fills assemblés à partir de cellules d'un temps (doubles, descentes de toms, flams, triolets en 12/8), en crescendo, avec la grosse caisse sur les temps et la cymbale de tempo coupée.
- ✅ **Fills de phrase** : pickup en fin de phrase de 4 mesures, fill de 1 à 2 temps en fin de phrase de 8 mesures, fill plus long en fin de section quand l'énergie monte.
- ✅ **Arrivée** : crash et grosse caisse sur le premier temps de la section suivante, crash gauche et droit en alternance.
- ✅ **Transitions déclaratives** : `none`, `pickup`, `fill`, `big`, `build` (roulement avant un refrain), modifiables dans l'onglet Sections.
- ⬜ **Écoute dans REAPER** : fills, roulements et arrivées dans EZdrummer.

## Sprint 13 — Arrangement du morceau (v0.13) ⬜

- ⬜ **Énergie évolutive** : rampe `energy = { from, to }` sur les vélocités, la densité du groove et l'automation.
- ⬜ **Breaks et coups d'ensemble** (`hits`) joués par la batterie et la basse, affichés dans le guide d'accords.
- ⬜ **Feels** `half_time` et `double_time` par section.
- ⬜ **Vraies fins** : `ending = "hit" | "ring" | "choke"`.
- ⬜ **Structures enrichies** : pré-refrain et pont pour le Hard Rock, breakdown ou stop-time selon le style.

## Sprint 14 — Basse plus vivante (v0.14) ⬜

- ⬜ **Notes de passage** avant les changements d'accord (chromatique, quinte, gamme), selon le seed.
- ⬜ **Phrasé par section** et nouveaux modes `octaves` et `drive`.
- ⬜ **Fills de basse** synchronisés avec ceux de la batterie, vers la fondamentale de la section suivante.
- ⬜ **Breaks** : la basse joue les coups d'ensemble et se tait entre eux.
- ⬜ **Tessiture** contrôlée par le validateur.

## Sprint 15 — Mise à jour du MIDI seul (v0.15) ⬜

- ⬜ **Marquage** de tout ce que le script crée (`P_EXT:HRC_ID`) : pistes, items, marqueurs, régions.
- ⬜ **Mode `update_midi`** : réécrit le tempo, la structure, le MIDI, les accords et l'automation sans recréer les pistes, les plugins ni toucher aux prises audio.
- ⬜ **Projets plus anciens** : pistes retrouvées par leur nom, refus clair si une piste MIDI manque.
- ⬜ **Bouton « Update MIDI only »** dans la fenêtre.

## Sprint 16 — Stabilisation et distribution (v1.0) ⬜

- ⬜ **Paquet ReaPack** : `index.xml` et en-tête de métadonnées.
- ⬜ **Documentation** dans `Docs/` : installation, création d'un style, format des données.
- ⬜ **Tests de bout en bout** dans REAPER : pistes, sends, régions, notes MIDI.
- ⬜ **Version 1.0.0** : CHANGELOG consolidé (titres manquants pour les commits #0001 à #0024) et tag git.

---

## Vérification à chaque sprint

- `lua Tests/run.lua` passe, en local et sur GitHub Actions.
- `Main.lua` s'exécute dans REAPER sous Windows et macOS : la console affiche « Done. » sans erreur.
- Contrôles manuels : tempo et signature, pistes et couleurs, sends FX, régions alignées sur les sections, notes MIDI sur la grille.
