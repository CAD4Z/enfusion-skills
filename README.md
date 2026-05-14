# DayZ Scope

Claude Code plugin for DayZ modding — skills, agents, and reference docs for working with Enforce Script, layouts, configs, and engine internals.

## What's inside

### Skills

| Skill | Triggers on | Purpose |
|-------|-------------|---------|
| `dayz-scripting` | `**/*.c` files | Enforce Script conventions, critical language rules, modded-class semantics, memory/ref lifecycle, engine pitfalls |
| `dayz-ui` | `**/*.layout`, `**/*.styles`, `**/*.imageset` | UI formats, widget scripting, menus, HUD, critical UI rules (Unlink, input excludes, CALL_CATEGORY_GUI, etc.) |

### Agents

| Agent | Purpose |
|-------|---------|
| `dayz-meticulous-reviewer` | Reviews staged changes or the whole project for DayZ-specific issues. Reports prioritized findings — does not edit. |
| `dayz-reverse-engineer` | Answers API/engine questions by searching local docs first, then extracted game scripts on the `P:` drive. |

### References

`references/` contains 80 markdown files covering the Enforce Script API (`1_Core` → `5_Mission`), AI systems, configs, and class catalogs. Used primarily by the `dayz-reverse-engineer` agent, but also readable directly.

## Install

```
/plugin marketplace add TomatoLabz/DayZScope
/plugin install dayz-scope@tomatolabz
```

## External dependencies

The `dayz-reverse-engineer` agent reads vanilla DayZ scripts as ground truth when local docs are insufficient. These must be extracted to the `P:` drive via DayZ Tools (the standard modding setup):

- `P:/scripts/1_core`, `2_gamelib`, `3_game`, `4_world`, `5_mission` — engine and game scripts
- `P:/gui/layouts`, `looknfeel`, `imagesets`, `fonts` — vanilla UI assets

If the `P:` drive isn't set up, the agent will still work using local references only — answers may just be less verified.

## Project structure

```
.
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── agents/
│   ├── dayz-meticulous-reviewer.md
│   └── dayz-reverse-engineer.md
├── skills/
│   ├── dayz-scripting/
│   │   ├── SKILL.md
│   │   └── reference/
│   └── dayz-ui/
│       ├── SKILL.md
│       └── reference/
├── references/
│   └── DayZ/
│       ├── Configs/
│       └── Scripts/{ai,api/{1_Core,2_GameLib,3_Game,4_World,5_Mission}}
├── scripts/
│   └── fix_paa_alpha.py
└── CLAUDE.md
```
