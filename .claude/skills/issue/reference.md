# Issue Skill — Reference

## Branch Naming Convention

| Component | Rule | Example |
|-----------|------|---------|
| Issue number | Digits from GitHub issue | `3` |
| Separator | Single hyphen | `-` |
| Slug | Lowercase, hyphens, max 40 chars | `bloeddruk-card-wys-volledige-lesing` |
| Full branch | `N-slug` | `3-bloeddruk-card-wys-volledige-lesing` |

### Slug Generation

1. Take issue title
2. Convert to lowercase
3. Replace spaces and special characters with hyphens
4. Collapse consecutive hyphens to single hyphen
5. Strip leading/trailing hyphens
6. Truncate to 40 characters (break at last hyphen before limit)

```bash
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-40 | sed 's/-$//')
branch="${issue_number}-${slug}"
```

## PR Template

```markdown
## Summary
<2-3 bullet points summarizing changes>

closes #N

## Test plan
- [ ] <verification step 1>
- [ ] <verification step 2>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## GitHub Labels

| Label | Color | Created When | Applied | Removed |
|-------|-------|-------------|---------|---------|
| `in-progress` | `#0E8A16` (green) | First `/issue` run if missing | Flow A Step 4 | Flow B Step 6 |

## Error Handling

| Scenario | Action |
|----------|--------|
| No open issues | Print "No open issues found." and stop |
| Branch already exists | Ask user: switch to it or create with suffix |
| Label doesn't exist | Create it automatically with `gh label create` |
| `gh` CLI not authenticated | Print error and suggest `gh auth login` |
| Issue already has `in-progress` label | Warn that someone may be working on it, ask to proceed |
| `/validate-change` fails | Block PR creation, show findings, ask user to fix |
| No commits on branch | Block PR creation — nothing to ship |
| Branch not pushed | Auto-push with `git push -u origin HEAD` |

## Argument Handling

| Invocation | Behavior |
|------------|----------|
| `/issue` | Context-aware: Flow A on main, Flow B on issue branch |
| `/issue 3` | Skip issue picker, go directly to issue #3 (Flow A only) |
| `/issue pick` | Synonym for Flow A (ignore branch context) |
| `/issue pr` | Synonym for Flow B (error if not on issue branch) |

## Workflow Diagram

```
main branch                    issue branch (N-slug)
    │                               │
    ├─ /issue                       ├─ /issue
    │   ├─ gh issue list            │   ├─ extract issue #N
    │   ├─ pick issue               │   ├─ /validate-change ← hard gate
    │   ├─ create branch N-slug     │   ├─ /commit (auto refs #N)
    │   ├─ label: in-progress       │   ├─ git push
    │   └─ /brainstorm              │   ├─ gh pr create (closes #N)
    │                               │   └─ remove in-progress label
    ▼                               ▼
    implement normally              PR created, issue auto-closes on merge
```
