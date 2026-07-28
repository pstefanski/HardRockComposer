# HardRock Composer Architecture

Ce document décrit les règles fondamentales du moteur.

Ces règles sont considérées comme stables et doivent être respectées lors des futures évolutions.

---

# 1. Data Driven

Le projet est entièrement piloté par les données.

Les fichiers présents dans `Data/` décrivent **ce qui doit être construit**.

Les modules présents dans `Core/` décrivent **comment le construire**.

---

# 2. Identifiants stables

Toute entité persistante possède un identifiant unique.

Exemples :

- groupes
- pistes
- bus
- plugins
- styles

Le champ `name` est uniquement destiné à l'affichage.

Le champ `id` est utilisé par le moteur.

---

# 3. BuildContext

Le `BuildContext` contient toutes les références créées pendant la génération.

Il est partagé entre tous les modules.

Les modules ne recherchent jamais directement des pistes dans REAPER.

---

# 4. Registry

Le registre permet un accès immédiat aux objets construits.

Exemple :

```lua
context.registry.tracks.kick
context.registry.groups.drums
```

Les listes (`tracks`, `groups`) sont conservées afin de préserver l'ordre de création.

---

# 5. REAPER Wrapper

Toute interaction avec l'API REAPER passe par `Core/Reaper.lua`.

Aucun module ne doit appeler directement `reaper.*`.

---

# 6. Routing

Les dossiers REAPER servent uniquement à organiser le projet.

Ils ne représentent pas des bus audio.

Les bus sont des pistes normales.

Le routage audio est réalisé exclusivement par des Track Sends.

Lorsqu'une piste possède un `route_to` :

- un Track Send est créé ;
- le Parent Send est automatiquement désactivé.

---

# 7. Modules

Chaque module possède une responsabilité unique.

Exemples :

- Tracks
- Routing
- Colors
- Plugins
- Markers

Les modules communiquent uniquement via le `BuildContext`.

---

# 8. Objectif

Le moteur doit être :

- déterministe ;
- modulaire ;
- testable ;
- extensible.

La même configuration doit toujours produire exactement le même projet REAPER.