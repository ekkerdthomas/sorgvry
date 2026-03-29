---
name: issue
description: Pick a GitHub issue to work on, or create a PR to close the current issue.
user-invocable: true
argument-hint: [issue number]
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion, Skill
model: opus
---

# Issue-Driven Dev

**PURPOSE**: Orchestrate the full dev lifecycle from GitHub issue to merged PR. Context-aware — detects whether you're starting or finishing work.

## Context Detection

```bash
branch=$(git branch --show-current)
```

- If branch matches `^\d+-` → **Flow B** (finish: validate → commit → PR)
- Otherwise → **Flow A** (start: pick issue → branch → brainstorm)

## Flow A: Pick an Issue (on `main` or non-issue branch)

### Step 1: List Issues

If an issue number was passed as argument, skip to Step 3.

```bash
gh issue list --state open --limit 20
```

Present issues to user via `AskUserQuestion`. Include issue number and title.

### Step 2: Read Issue Details

```bash
gh issue view N
```

Display the issue body to understand full context.

### Step 3: Create Branch

Generate slug from issue title:
- Lowercase
- Replace spaces and special chars with hyphens
- Strip consecutive hyphens
- Max 40 characters
- Prefix with issue number

```bash
git checkout -b N-slug
```

Example: Issue #3 "Bloeddruk card: wys volledige lesing" → `3-bloeddruk-card-wys-volledige-lesing`

### Step 4: Label Issue

```bash
gh issue edit N --add-label in-progress
```

If the label doesn't exist, create it first:
```bash
gh label create in-progress --color 0E8A16 --description "Currently being worked on"
```

### Step 5: Invoke Brainstorm

Invoke `/brainstorm` with the issue title and body as the topic argument. This kicks off the design phase.

**After brainstorm completes**, the user implements normally. When ready to ship, run `/issue` again (now on the issue branch → Flow B).

## Flow B: Create PR (on issue branch matching `^\d+-`)

### Step 1: Extract Issue Number

Parse issue number from branch name (digits before first `-`).

```bash
branch=$(git branch --show-current)
issue_number=$(echo "$branch" | grep -oP '^\d+')
```

### Step 2: Validate (Hard Gate)

Invoke `/validate-change`. If it fails or hasn't been run, **block PR creation**.

### Step 3: Commit

Invoke `/commit`. The modified `/commit` skill auto-appends `refs #N` to the commit message (see Step 4.5 in commit skill).

### Step 4: Push

```bash
git push -u origin HEAD
```

### Step 5: Create PR

```bash
gh pr create --title "<PR title>" --body "$(cat <<'EOF'
## Summary
<bullet points summarizing changes>

closes #N

## Test plan
<verification steps>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- PR title: derived from issue title or first commit subject
- Body must include `closes #N` to auto-close the issue on merge

### Step 6: Clean Up Labels

```bash
gh issue edit N --remove-label in-progress
```

## Key Rules

- **One branch = one issue** — never combine multiple issues in a single branch
- **Branch naming**: `N-slug` where N is the issue number (e.g. `3-fix-card-overflow`)
- **Flow A auto-invokes /brainstorm** — skip only if the issue is trivially small (single-line fix)
- **Flow B hard-gates on /validate-change** — no PR without passing validation
- **Use `refs` in commits, `closes` in PRs** — commits reference, PRs close

## Related Skills

- **Auto-invoked**: `/brainstorm` (Flow A, Step 5), `/validate-change` (Flow B, Step 2), `/commit` (Flow B, Step 3)
- **See also**: `/tdd` for test-driven implementation between Flow A and Flow B
- **See also**: `/deploy` after PR is merged

## Pressure Tested

| Scenario | Pressure Type | Skill Defense |
|----------|--------------|---------------|
| "Skip brainstorm, this is a tiny fix" | YAGNI | Key Rules: skip brainstorm only for trivially small issues |
| "Just push directly, no PR needed" | shortcut | Flow B always creates a PR — direct push bypasses traceability |
| "Create PR without validating" | time pressure | Step 2 is a hard gate — blocks without /validate-change |
| "Work on multiple issues in one branch" | scope creep | Key Rules: one branch = one issue |
