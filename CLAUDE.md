# Enfusion Skills

Agent skills for DayZ modding, shipped as a plugin to Claude Code and as a skill set to every other agent. This file governs work **on** this repository; the skills under `skills/` are the product.

## Shipping

Two routes out, and they are not symmetrical. Claude Code installs this repository as a **plugin**, so `.claude-plugin/plugin.json` names every skill directory explicitly. Every other agent — Codex included — gets the skills through the **`npx skills` installer**, which needs no manifest: it reads the flat `skills/<name>/SKILL.md` layout directly and copies each skill whole. So `skills/` holds shipped skills only — a draft or a retired skill lives somewhere else or not at all.

- **Bump `version` in `.claude-plugin/plugin.json`.** Claude Code reads it to decide when installed users see an update. The installer route is not versioned; it tracks the default branch.
- **Validate both routes** after touching a manifest or any frontmatter: `claude plugin validate . --strict`, and `npx skills@latest add <repo-root> --list`, which must list every skill.
- **Keep frontmatter parseable by a strict YAML parser.** The installer parses more strictly than either harness and drops a skill that fails, saying so only in a passing warning — a `: ` inside an unquoted `description` costs users that skill across every agent at once, silently. Quote any value carrying a colon.
- **Every skill carries an `agents/openai.yaml`** beside its `SKILL.md`, holding `interface.display_name` and `interface.short_description`. The installer copies it along with the skill, and it is what Codex reads — its own built-in skills carry the same file.
- **Invocation is declared in both harnesses or neither.** User-invoked: `disable-model-invocation: true` in the frontmatter plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, and the `description` is human-facing. Model-invoked: omit both, and the `description` carries the trigger branches.
- **The README lists every skill**, grouped into User-invoked and Model-invoked, each name linked to its `SKILL.md`.

## Writing a skill

- **`SKILL.md` carries what every branch needs.** Anything only one branch reaches goes into `reference/`, behind a pointer naming the file and the condition for reading it.
- **One meaning, one home.** Where two skills need the same material it lives in the skill that owns it, and the other reaches it by calling the Skill tool. A copy is licensed only across a context boundary a pointer cannot cross — a sub-agent brief — and is marked as such where it appears.
- **Cross-skill dependencies read `call the Skill tool with "name"`** — one skill per call. Not a `/name` form, and never a `../other-skill/file.md` path: a name survives installation, a relative path across skills does not.
- **State a rule positively, with its consequence attached.** "Release by nulling the reference; `delete` on an entity crashes" beats "do not use `delete`" — a prohibition drags the banned behaviour into context and half-reads as an instruction to do it.
- **Links inside `references/` are relative to the file holding them.** A repo-root-relative path resolves only while the agent sits in this repository, which it never does once the plugin is installed.
- **Delete what the model already does by default.** An instruction that changes no behaviour costs context and says nothing; test it by removing it and running the skill.

## Domain

DayZ is a multiplayer post-apocalyptic survival game on the Enfusion Engine, split into a client and a server — the server holds the core gameplay configuration, and both are moddable. Modding runs through DayZ Tools, which covers every component and includes Terrain Builder (map), Object Builder (objects), Central Economy (loot), and Workbench (the engine's minimal IDE). Mods and game files ship as PBO archives rather than plain files. In-game logic is written in Enforce Script, a C++-like language whose sources ship readable.

Reference: `@skills/dayz-lookup/references/INDEX.md`

Never build a PBO or launch the client or server — every change is tested by hand by the developer.
