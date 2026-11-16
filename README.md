# 🎸 HardRock Composer

> A professional REAPER project generator for rock and hard rock production.

HardRock Composer is an open-source **ReaScript (Lua)** project that automatically creates a fully organized REAPER session for composing and producing energetic rock music.

Instead of starting from a static template, HardRock Composer generates a complete project structure including tracks, folders, routing, markers, regions, FX buses, plugin chains and MIDI drum patterns.

![](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExNTB3MjFsOWkyMTk2bDF6eGpvdTVoc25lMTg0YW9sZWhpcTZpbjJtdCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ifCT1dv4jfnSo/giphy.gif)

---

## ✨ Features

### Current

* Project reset, tempo and time signature setup
* Data validation before generation (every error reported at once)
* Track folders, colorized track layout and track properties
* Bus routing with configurable sends (mode and level)
* Automatic plugin insertion with HRC presets, AU/VST3 alternatives,
  stock REAPER fallbacks and an end-of-build report
* EZdrummer 3 multi-output routing (32 channels)
* TONEX guitar and bass amps, parallel bass processing
* UAD bus, vocal and master processing chains
* FX returns: Plate, Room, Hall and Delay (Valhalla)
* Song structure, markers and colored regions
* MIDI drum engine: section grooves, variations, fills, transitions,
  section dynamics and deterministic humanization
* Five styles (Hard, Classic, Blues, Heavy, Punk Rock) with swing,
  12/8 support and seeded song structure variants
* Chord progressions per section: chord guide track and generated bass
  line (kick-locked, driving eighths or boogie)
* Bus and reverb levels automated from the section energy
* Optional count-in

### Planned

* Graphical user interface (ReaImGui)
* ReaPack distribution

See [ROADMAP.md](ROADMAP.md) for the detailed plan.

---

# Supported Software

* REAPER 7.78+
* Windows 11 and macOS

Linux should work but is untested.

The default track layout uses EZdrummer 3, IK Multimedia TONEX,
Universal Audio UADx plugins (VST3 or AU) and ValhallaDelay, with their
`HRC …` presets. Missing plugins are replaced by stock REAPER plugins
(ReaComp, ReaEQ, ReaVerbate, ReaDelay) or skipped when optional, and missing
presets keep the default settings. A report is printed at the end of the
generation.

---

# Usage

1. Copy the `HardRockComposer` folder into REAPER's `Scripts` folder.
2. In REAPER: *Actions → Show action list → New action → Load ReaScript…*
   and select `Main.lua`.
3. Run the action. ⚠️ By default it **deletes every track** of the current
   project (see `Config.ResetProject`).

### Presets

The `HRC …` presets are created on one machine. To use them everywhere, run
the **`ExportPresets.lua`** action once on that machine (it regenerates the
project), then commit and push the `Presets/` folder. On the other machines,
the generation applies these saved plugin states when REAPER does not know
the preset. See [Presets/README.md](Presets/README.md).

### Styles

Choose the style in `Config.lua`:

```lua
Config.Style = "BluesRock"
```

| Style | Feel |
| ----- | ---- |
| `HardRock` | 140 BPM, straight 4/4 |
| `ClassicRock` | 120 BPM, 4/4 with a light shuffle |
| `BluesRock` | 12/8 shuffle, 12-bar verses, optional stop time |
| `HeavyRock` | 145 BPM, gallop and double kick, optional breakdown |
| `PunkRock` | 190 BPM, eighth-note drive and skank beat |

Each style lives in `Styles/<Style>/` (settings, structure, drum patterns).
Change `structure_seed` in its `SongSettings.lua` to get another variant of
the song (optional bridge, breakdown or extra chorus).

---

# Tests

The engine can be tested outside REAPER with Lua 5.4+:

```bash
lua Tests/run.lua
```

---

# Project Structure

```text
HardRockComposer/

├── Main.lua          Entry point
├── Config.lua        Engine options
├── Version.lua

├── Core/             Engine logic (one responsibility per module)
├── ExportPresets.lua Saves the HRC presets into Presets/
├── Bootstrap.lua     Shared setup of the REAPER entry scripts

├── Data/             Shared data: track layout, colors, MIDI note map
├── Styles/           One folder per style: settings, structure, drums
├── Presets/          Exported plugin states of the HRC presets
└── Tests/            Test suite with a mocked REAPER API
```

---

# Philosophy

HardRock Composer is **data-driven**.

The engine itself does not contain hard-coded song structures or musical styles.

Everything is described through configuration files, allowing new styles to be added without modifying the core engine.

Examples:

* Hard Rock
* Classic Rock
* Blues Rock
* Heavy Rock
* Punk Rock

---

# Long-Term Goals

The objective is to generate a production-ready REAPER project in a single click.

Routing, FX buses, drum grooves and the song structure are already generated.
Future versions will also:

* Generate bass lines and chord guides
* Provide a graphical interface to configure the song

---

# Contributing

Contributions, suggestions, bug reports and pull requests are welcome.

Please open an issue before implementing major changes.

---

# License

Released under the MIT License.

---

# Status

🚧 **Early Development**

This project is currently under active development.
