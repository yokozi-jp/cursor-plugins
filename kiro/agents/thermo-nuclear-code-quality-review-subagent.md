---
name: thermo-nuclear-code-quality-review-subagent
description: Thermo-nuclear code quality audit (maintainability, structure, 1k-line rule, spaghetti, code-judo). Invoked via Task after a parent gathers diff and file contents. Loads rubric from the thermo-nuclear-code-quality-review skill in the Thermos plugin.
model: claude-opus-5.5
effortLevel: high
tools: ["read", "shell"]
permissions:
  rules:
    - capability: shell
      match: ["git commit *", "git push *", "git reset *", "git checkout *", "git restore *", "git switch *", "git stash *", "git rebase *", "git merge *", "git apply *", "git add *", "git cherry-pick *", "git pull *", "git clean *", "git am *", "git revert *", "gh pr comment *", "gh pr review *", "gh pr edit *", "gh pr merge *", "gh pr close *", "gh pr ready *", "gh pr create *", "gh issue *", "gh api *-X *", "gh api *--method*", "gh api *-f *", "gh api *-F *", "gh api *--field*", "gh api *--input*", "glab mr note *", "glab mr merge *"]
      effect: deny
---
