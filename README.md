# 🎸 HardRock Composer

> A professional REAPER project generator for rock and hard rock production.

HardRock Composer is an open-source **ReaScript (Lua)** project that automatically creates a fully organized REAPER session for composing and producing energetic rock music.

Instead of starting from a static template, HardRock Composer generates a complete project structure including tracks, folders, routing, markers, regions, FX buses, and (in future releases) MIDI drum patterns and plugin configuration.

![](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExNTB3MjFsOWkyMTk2bDF6eGpvdTVoc25lMTg0YW9sZWhpcTZpbjJtdCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ifCT1dv4jfnSo/giphy.gif)

---

## ✨ Features

### Current

* Project creation
* Tempo and time signature setup
* Track folder generation
* Colorized track layout
* Song markers
* Song regions
* Production notes track
* Mix checklist track

### Planned

* Automatic plugin detection
* EZdrummer 3 integration
* EZdrummer multi-output routing
* TONEX integration
* UAD FX support
* Valhalla FX buses
* Drum groove generator
* Song structure generator
* Humanized MIDI engine
* Multiple rock style presets
* Graphical user interface (GUI)

---

# Supported Software

* REAPER 7.78+
* Windows 11

Future support for macOS and Linux is planned.

---

# Roadmap

| Version | Status               |
| ------- | -------------------- |
| v0.1    | Project architecture |
| v0.2    | Track generator      |
| v0.3    | Markers & Regions    |
| v0.4    | Routing engine       |
| v0.5    | Plugin detection     |
| v0.6    | FX chains            |
| v0.7    | MIDI engine          |
| v0.8    | GUI                  |
| v1.0    | Stable release       |

---

# Project Structure

```text
HardRockComposer/

├── Main.lua
├── Config.lua
├── Version.lua

├── Core/
├── Data/
├── Styles/
├── Assets/
├── Docs/
└── Tests/
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

A future version will automatically:

* Detect installed plugins
* Configure routing
* Generate drum grooves
* Build the song structure
* Create FX buses
* Prepare the mix session

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
