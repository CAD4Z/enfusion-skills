<div align="center">
    <a href="https://github.com/CAD4Z/enfusion-skills"><img src="https://github.com/user-attachments/assets/f554aa83-bc3e-4c86-a489-24caff9b2c9c"></a>

</div>

<div align="center">
    <img src="https://img.shields.io/github/issues/CAD4Z/enfusion-skills?style=for-the-badge" alt="open issues" />
    <img src="https://img.shields.io/badge/version-0.3.1-blue?style=for-the-badge" alt="version" />
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-PolyForm%20Strict%201.0.0-red?style=for-the-badge" alt="license" /></a>
</div>

<br />

<div align="center">
  📎Enfusion skills for your AI-Agents!
</div>

<div align="center">
  <sub>
    Built with love 
    &bull; Brought to you by <a href="https://github.com/CAD4Z">@CAD4Z</a>
    and other <a href="https://github.com/CAD4Z/enfusion-skills/graphs/contributors">contributors</a>
  </sub>
</div>

## Introduction

Agent skills and reference docs for DayZ modding — Enforce Script, layouts, configs, and engine internals.

Runs in **Claude Code** as a plugin, and in every other agent — Codex, Cursor, Cline, Windsurf, Copilot, Zed and the rest — through the `npx skills` installer. Every skill is one `SKILL.md` plus an `agents/openai.yaml` beside it; every harness reads the same body and they differ only in metadata.

## Skills

### Model-invoked

Reachable by the model or by you. Rich trigger phrasing in the description, so auto-invocation fires.

- **[dayz-scripting](./skills/dayz-scripting/SKILL.md)** — Enforce Script conventions and the five engine invariants the compiler will not catch. Fires on `.c` files.
- **[dayz-ui](./skills/dayz-ui/SKILL.md)** — `.layout` / `.styles` / `.imageset` formats, widget scripting, menus, HUD, and the UI invariants that fail silently. Fires on UI files.
- **[dayz-lookup](./skills/dayz-lookup/SKILL.md)** — answers an API or engine-behaviour question from source: project docs, then this plugin's reference set, then the extracted vanilla scripts on `P:`. Runs as a sub-agent and reports back with file paths, so the search never lands in your context.

### User-invoked

Run on request. Claude Code holds this with `disable-model-invocation: true`; Codex with `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, the same shape its own `review-agent` skill uses.

- **[dayz-review](./skills/dayz-review/SKILL.md)** — three-axis review of a change: **Standards** (does it follow the project's documented conventions?), **Runtime** (will it behave in game — pairing, lifecycle, client/server, packed paths?), and **Spec** (does it do what was asked?), run as three parallel sub-agents and reported side by side.

## References

`skills/dayz-lookup/references/` holds 80 markdown files covering the Enforce Script API (`1_Core` → `5_Mission`), AI systems, configs, and class catalogs. They live inside `dayz-lookup` because it is the only skill that reads them; everything else reaches that material by invoking the skill and getting a summary back.

## Install

Two ways in. The **Claude Code plugin** installs the set as a managed bundle that updates when this repo ships. The **`npx skills` installer** copies the skills into your project as ordinary files on disk, and covers every other agent.

**Claude Code**

```
/plugin marketplace add CAD4Z/enfusion-skills
/plugin install enfusion-skills@cad4z
```

**Codex, and every other agent**

```
npx skills@latest add CAD4Z/enfusion-skills
```

It detects the agents on your machine and asks which skills to take. Each skill is copied whole — `reference/`, `references/`, and `agents/openai.yaml` with it — into `.agents/skills/` and the agent's own path. `--skill dayz-scripting` takes one, `-a codex` targets a single agent, `-g` installs globally, and `npx skills update` pulls later changes. Nothing updates behind your back.

## External dependencies

`dayz-lookup` treats the vanilla DayZ scripts as ground truth when the docs run out. They come from the standard DayZ Tools extraction to the `P:` drive:

- `P:/scripts/1_core`, `2_gamelib`, `3_game`, `4_world`, `5_mission` — engine and game scripts
- `P:/gui/layouts`, `looknfeel`, `imagesets`, `fonts` — vanilla UI assets

Without `P:`, the lookup still answers from the local references and flags the answer as unverified.

## Project structure

```
.
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── skills/
│   ├── dayz-scripting/     SKILL.md + agents/openai.yaml + reference/
│   ├── dayz-ui/            SKILL.md + agents/openai.yaml + reference/
│   ├── dayz-lookup/        SKILL.md + agents/openai.yaml + references/ (80 files)
│   └── dayz-review/        SKILL.md + agents/openai.yaml
├── scripts/
│   └── fix_paa_alpha.py
├── AGENTS.md
├── CLAUDE.md
└── LICENSE
```

## License

PolyForm Strict 1.0.0 — see [LICENSE](./LICENSE). Source-available, not open source: you may read and use these skills for any noncommercial purpose, but not redistribute or modify them. DayZ and the Enfusion engine are the property of Bohemia Interactive.
