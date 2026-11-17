# pstack and thermos in Kiro CLI

English | [日本語](./README.ja.md)

This fork adds only `kiro/` to [cursor/plugins](https://github.com/cursor/plugins) and leaves upstream files unchanged. It installs pstack, thermos, and cursor-team-kit's `deslop`, `control-cli`, and `control-ui`, plus Kiro agents, steering, and a permissions template.

## Administrator: install into a repository

```bash
git clone https://github.com/yokozi-jp/cursor-plugins.git ~/cursor-plugins   # first time only
git -C ~/cursor-plugins pull
~/cursor-plugins/kiro/install.sh --repo <target repository>
cd <target repository> && git add .kiro && git commit -m "chore(kiro): add pstack and thermos" && git push
```

- Run the same commands to update. The files installed last time are replaced with the current version.
- Anything printed as `skip: ... already exists` keeps the repository's existing version instead of this one. To use this one, delete or rename the existing one, then run the command again.
- If your machine has no `~/.kiro/settings/permissions.yaml`, it is created too.

## Users: get started

After you clone the repository, run this once inside it:

```bash
mkdir -p ~/.kiro/settings && [ -e ~/.kiro/settings/permissions.yaml ] || cp .kiro/kiro-permissions.yaml ~/.kiro/settings/permissions.yaml
```

Start Kiro CLI. If "Trust this workspace?" appears, choose Trust. To update, run `git pull`.

## Don't

- Don't edit the skills or agents installed in a repository. The next update overwrites them. Make changes in this fork's `kiro/`.
- Don't edit files outside `kiro/` in this fork. They conflict at the next upstream sync.
- Don't name the permissions file `permissions.yml`. Only `.yaml` and `.json` load.
- Don't run `/setup-pstack`. In Kiro, the agent files set the models, and it isn't installed.

## Administrator: change this fork

- **Sync with upstream:** click "Sync fork" on GitHub, or run `git fetch upstream && git merge upstream/main && git push`. Then run the install commands in each repository that has it.
- **Change a model:** `model` and `effortLevel` in `kiro/agents/*.md`. List valid models with `kiro-cli chat --list-models`.
- **Change which skills install:** `skill_dirs` and `excluded_skills` in `kiro/install.sh`. Give a reason for each excluded skill, and name it on the line of `kiro/skills/kiro-adapter/SKILL.md` that cites `excluded_skills`. `install.sh` stops when a name is missing there.
- **Map a new Cursor name:** `kiro/skills/kiro-adapter/SKILL.md`. When an upstream skill starts using a Cursor name it doesn't map, add a row there.

## Every repository on your machine

For use without sharing with your team. Installs into `~/.kiro/`.

```bash
git clone https://github.com/yokozi-jp/cursor-plugins.git ~/cursor-plugins   # first time only
git -C ~/cursor-plugins pull && ~/cursor-plugins/kiro/install.sh
```
