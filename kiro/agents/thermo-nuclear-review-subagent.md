---
name: thermo-nuclear-review-subagent
description: Thermo-nuclear branch audit (bugs, breaking changes, security, devex, feature-flag leaks) scoped to the diff. Invoked via Task after a parent gathers diff and file contents. Loads rubric from the thermo-nuclear-review skill in the Thermos plugin.
model: claude-opus-5.5
effortLevel: high
tools: ["read", "shell"]
permissions:
  rules:
    - capability: shell
      match: ["git commit *", "git push *", "git reset *", "git checkout *", "git restore *", "git switch *", "git stash *", "git rebase *", "git merge *", "git apply *", "gh pr comment *", "gh pr review *", "gh pr edit *", "gh pr merge *", "glab mr note *", "glab mr merge *"]
      effect: deny
---
