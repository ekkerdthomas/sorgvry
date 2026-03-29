# Issue-Driven Dev — Design

**Date**: 2026-03-29
**Status**: Draft

## Problem

Commits and PRs are disconnected from GitHub issues. No traceability from "why" (issue) to "what" (code change). No structured workflow from issue selection to merged PR.

## Solution

A single context-aware `/issue` skill that orchestrates the full dev lifecycle:

- **On `main` branch**: Pick an issue → create branch → auto-invoke `/brainstorm`
- **On issue branch** (`N-slug`): Run `/validate-change` → `/commit` (with `refs #N`) → create PR (`closes #N`)

Plus a modification to `/commit` to auto-detect issue branches and append `refs #N`.

## Design

### 1. `/issue` Skill (`/.claude/skills/issue/SKILL.md`)

**Context detection**: Read current branch name via `git branch --show-current`.

#### Flow A: On `main` (or any non-issue branch)

1. Run `gh issue list --state open --limit 20` and present issues to user via `AskUserQuestion`
2. User picks an issue
3. Generate slug from issue title (lowercase, hyphens, max 40 chars)
4. Create and checkout branch: `git checkout -b N-slug` (e.g. `3-fix-card-overflow`)
5. Add `in-progress` label to issue: `gh issue edit N --add-label in-progress`
6. Auto-invoke `/brainstorm` with the issue title and body as context
7. After brainstorm completes → user implements normally

#### Flow B: On issue branch (matches pattern `^\d+-`)

1. Extract issue number from branch name (digits before first `-`)
2. Run `/validate-change` (hard gate — block if it fails)
3. Run `/commit` (which will auto-append `refs #N` — see section 2)
4. Push branch: `git push -u origin HEAD`
5. Create PR via `gh pr create`:
   - Title: from first commit or ask user
   - Body: `closes #N` + summary of changes
   - Auto-link to issue
6. Remove `in-progress` label, GitHub auto-closes issue on merge

### 2. `/commit` Modification

Add a new step between current Step 4 (Format and Analyze) and Step 5 (Stage and Commit):

**Step 4.5: Issue Reference Detection**

```
branch=$(git branch --show-current)
if [[ "$branch" =~ ^([0-9]+)- ]]; then
  issue_number="${BASH_REMATCH[1]}"
  # Append "refs #N" to commit message footer
fi
```

- Only appends `refs #N` (not `closes #N` — that's the PR's job)
- Placed in the commit message footer, before `Co-Authored-By`

### 3. Branch Naming Convention

| Pattern | Example | Usage |
|---------|---------|-------|
| `N-slug` | `3-fix-card-overflow` | Issue-linked branch |
| `main` | — | Default branch |

- Slug derived from issue title: lowercase, spaces→hyphens, strip special chars, max 40 chars
- Issue number is always the prefix before the first hyphen

### 4. GitHub Labels

| Label | When Applied | When Removed |
|-------|-------------|--------------|
| `in-progress` | `/issue` picks the issue (Flow A) | PR is created (Flow B) |

### 5. Skill Metadata

```yaml
name: issue
description: Pick a GitHub issue to work on, or create a PR to close the current issue.
user-invocable: true
argument-hint: [optional issue number]
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion, Skill
model: opus
```

- `argument-hint`: Optional issue number to skip the picker (e.g., `/issue 3`)
- Uses `Skill` tool to invoke `/brainstorm`, `/validate-change`, and `/commit`

## Files Touched

| File | Action |
|------|--------|
| `.claude/skills/issue/SKILL.md` | **New** — the `/issue` skill |
| `.claude/skills/commit/SKILL.md` | **Edit** — add Step 4.5 issue reference detection |

## Non-Goals

- No GitHub Actions automation (keep it Claude Code native)
- No issue creation from this skill (use `gh issue create` directly)
- No multi-issue branches (one branch = one issue)

## Related Skills

- `/brainstorm` — invoked automatically after issue pick
- `/validate-change` — hard gate before PR creation
- `/commit` — modified to auto-reference issues
