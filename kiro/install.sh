#!/usr/bin/env bash
# Install pstack, thermos, and three cursor-team-kit skills into Kiro CLI.
#   kiro/install.sh --repo <dir>   Into <dir>/.kiro, for that repository. Commit what it adds.
#   kiro/install.sh                Into ~/.kiro, for every repository on this machine.
# Both write ~/.kiro/settings/permissions.yaml when it does not exist.
# Rerun to update. It replaces what it installed before and never touches other files.
# .kiro/.kiro-plugins-installed starts with "# cursor-plugins <commit>", then lists each installed path and its content_hash, tab-separated.
# With --repo, the commit must be clean so that the recorded commit reproduces the installed files.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kiro_src="$src/kiro"

# Skills that are not installed. Add the reason when you add a name.
#   setup-pstack     Models are set in kiro/agents/*.md instead.
#   make-bot-ui      Needs Cursor's update_state tool and Routines panel.
#   ketchup-video    Needs a chat that embeds video.
#   reflect          Rewrites installed skills, so the installed files stop matching their recorded hashes.
excluded_skills=(setup-pstack make-bot-ui ketchup-video reflect)

skill_dirs() {
  local d name
  for d in "$src"/pstack/skills/*/ "$src"/thermos/skills/*/ "$kiro_src"/skills/*/; do
    name="$(basename "$d")"
    [[ " ${excluded_skills[*]} " == *" $name "* ]] && continue
    echo "${d%/}"
  done
  for d in deslop control-cli control-ui; do echo "$src/cursor-team-kit/skills/$d"; done
}

# Agent file in kiro/agents -> upstream file whose body it takes. Empty: the Kiro file has its own body.
agent_body_source() {
  case "$1" in
    comment-sicko) echo "$src/pstack/agents/comment-sicko.md" ;;
    thermo-nuclear-review-subagent | thermo-nuclear-code-quality-review-subagent) echo "$src/thermos/agents/$1.md" ;;
    *) echo "" ;;
  esac
}

warn() { printf 'skip: %s\n' "$*" >&2; }

# A manifest line may only name a skill, agent, or steering file directly under .kiro/. Update deletes what it names.
valid_manifest_path() { [[ "$1" =~ ^(skills|agents|steering)/[^/]+$ || "$1" == kiro-permissions.yaml ]]; }

source_commit() {
  local commit
  commit="$(git -C "$src" rev-parse HEAD)" || { echo "$src is not a git checkout, so the source commit is unknown." >&2; exit 1; }
  [[ -z "$(git -C "$src" status --porcelain)" ]] || commit="$commit-dirty"
  echo "$commit"
}

# content_hash <path>: SHA-256 over each file's relative path then its bytes, files in byte order.
# A file hashes as itself with an empty path. Repositories can recompute it to detect local edits.
content_hash() (
  if [[ -d "$1" ]]; then
    cd "$1" && find . -type f | sed 's#^\./##' | LC_ALL=C sort | while IFS= read -r f; do printf '%s' "$f"; cat -- "$f"; done
  else
    cat -- "$1"
  fi | sha256sum | cut -d' ' -f1
)

install_into() {
  local kiro="$1" manifest="$1/.kiro-plugins-installed" old name f body
  mkdir -p "$kiro/skills" "$kiro/agents" "$kiro/steering"

  for old in "$manifest" "$kiro/.pstack-installed"; do
    [[ -f "$old" ]] || continue
    while IFS=$'\t' read -r name _; do
      [[ -z "$name" || "$name" == \#* ]] && continue
      valid_manifest_path "$name" || { warn "$old names $name, which is not a skill, agent, or steering file. Left in place."; continue; }
      rm -rf "${kiro:?}/$name"
    done < "$old"
    rm "$old"
  done

  : > "$manifest.new"
  claim() {
    if [[ -e "$kiro/$1" || -L "$kiro/$1" ]]; then warn "$kiro/$1 already exists"; return 1; fi
    echo "$1" >> "$manifest.new"
  }

  while IFS= read -r f; do
    name="skills/$(basename "$f")"
    claim "$name" && cp -R "$f" "$kiro/$name"
  done < <(skill_dirs)

  for f in "$kiro_src"/agents/*.md; do
    name="agents/$(basename "$f")"
    claim "$name" || continue
    body="$(agent_body_source "$(basename "$f" .md)")"
    if [[ -n "$body" ]]; then
      { cat "$f"; awk 'c>=2{print} /^---$/{c++}' "$body"; } > "$kiro/$name"
    else
      cp "$f" "$kiro/$name"
    fi
  done

  for f in "$kiro_src"/steering/*.md; do
    name="steering/$(basename "$f")"
    claim "$name" && cp "$f" "$kiro/$name"
  done

  {
    printf '# cursor-plugins %s\n' "$(source_commit)"
    while IFS= read -r name; do
      printf '%s\t%s\n' "$name" "$(content_hash "$kiro/$name")"
    done < "$manifest.new"
  } > "$manifest"
  rm "$manifest.new"
}

install_user_permissions() {
  local dir="$HOME/.kiro/settings" perms="$HOME/.kiro/settings/permissions.yaml"
  mkdir -p "$dir"
  if [[ ! -e "$perms" && ! -e "$dir/permissions.json" ]]; then
    cp "$kiro_src/permissions.yaml" "$perms"
    echo "wrote $perms"
  elif ! cmp -s "$kiro_src/permissions.yaml" "$perms"; then
    warn "kept your $perms. Merge in the rules from $kiro_src/permissions.yaml."
  fi
}

case "${1:-}" in
  --repo)
    [[ -n "${2:-}" ]] || { echo "usage: $0 --repo <dir>" >&2; exit 2; }
    repo="$(cd "$2" && pwd)"
    [[ "$repo" == "$src" ]] && { echo "Install into another repository, not this one." >&2; exit 1; }
    [[ "$(source_commit)" != *-dirty ]] || { echo "Commit or stash your changes in $src first. The manifest records the commit that produced the files." >&2; exit 1; }
    rm -f "$repo/.kiro/kiro-permissions.yaml"
    install_into "$repo/.kiro"
    cp "$kiro_src/permissions.yaml" "$repo/.kiro/kiro-permissions.yaml"
    printf 'kiro-permissions.yaml\t%s\n' "$(content_hash "$repo/.kiro/kiro-permissions.yaml")" >> "$repo/.kiro/.kiro-plugins-installed"
    install_user_permissions
    echo "Installed into $repo/.kiro. Commit .kiro/."
    ;;
  "")
    install_into "$HOME/.kiro"
    install_user_permissions
    echo "Installed into $HOME/.kiro."
    ;;
  *) echo "usage: $0 [--repo <dir>]" >&2; exit 2 ;;
esac
