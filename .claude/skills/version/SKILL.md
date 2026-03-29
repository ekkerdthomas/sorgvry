---
name: version
description: Analyze git history and suggest semantic version bumps per package. Use when preparing a release, checking what changed since the last version tag, or before deploying.
user-invocable: true
argument-hint: [--dry-run]
allowed-tools: Bash, Read, Edit, Grep, Glob, AskUserQuestion, Task
model: opus
---

# Version — Mono-Repo Release Bumper

**PURPOSE**: Analyze conventional commits since the last version tag and suggest per-package semver bumps with changelog generation.

## Steps

### 1. Clean Working Tree Check (HARD GATE)

```bash
git status --porcelain
```

If there are uncommitted changes, **block versioning**:

```
[BLOCK] Working tree has uncommitted changes. Run /commit first.
```

### 2. Find Base Reference

```bash
git tag -l 'v*' --sort=-v:refname | head -1
```

If no `v*` tag exists, fall back to the initial commit:

```bash
git rev-list --max-parents=0 HEAD
```

### 3. Collect and Classify Commits

```bash
git log <base>..HEAD --format="COMMIT:%H|||%s|||%b" --name-only
```

For each commit, parse:
- **Type** from subject: regex `^(\w+)(\(.+\))?(!)?:\s` (group 1 = type, group 3 = breaking)
- **Breaking** flag: `!` after type OR `BREAKING CHANGE` in body
- **Packages touched**: map changed file paths to packages by prefix

### 4. Map Paths to Packages

| Path prefix | Package |
|-------------|---------|
| `app/` | sorgvry (app) |
| `backend/` | sorgvry_backend |
| `packages/sorgvry_shared/` | sorgvry_shared |
| anything else | skip |

A commit touching multiple packages counts toward all matched packages.

### 5. Determine Bump Severity Per Package

| Commit type | Severity |
|-------------|----------|
| `feat` | **minor** |
| `fix`, `refactor`, `style`, `chore`, `docs`, `test`, `perf` | **patch** |
| breaking (`!` or `BREAKING CHANGE`) | **major** |

Take the **highest** severity per package. Packages with no commits get no bump.

### 6. Calculate New Versions

Read current versions from `pubspec.yaml` in each package. Apply bump:

- **major**: `X+1.0.0` — **minor**: `X.Y+1.0` — **patch**: `X.Y.Z+1`

For app and backend: also increment build number (`+N` becomes `+N+1`). Shared has no build number.

### 7. Present Summary

Display a table:

```
| Package | Current | Bump | New | Key Commits |
|---------|---------|------|-----|-------------|
| app     | 0.1.0+1 | minor | 0.2.0+2 | feat: redesign meds... |
```

List up to 3 key commits per package (highest severity first). **If `--dry-run`, stop here.**

### 8. Confirm

Ask the user to approve or adjust bumps. Recalculate if they request overrides.

### 9. Apply

Edit the `version:` line in each bumped package's `pubspec.yaml`.

### 10. Generate Changelog

Create or prepend to root `CHANGELOG.md`. Format per [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [v0.2.0] - 2026-03-29

### app
#### Added
- Redesign meds screen (d1a3f25)

### backend
#### Fixed
- ...
```

Type mapping: `feat`→Added, `fix`→Fixed, `refactor`/`perf`→Changed. Omit `style`/`chore`/`docs`/`test` unless the user requests them.

### 11. Tag

```bash
git tag v{new_app_version}
```

Local only. Inform the user: "Push with `git push --tags` when ready."

## Related Skills

- **See also**: `/commit` — ensures conventional commit format this skill depends on
- **See also**: `/deploy` — typically runs after versioning

## Pressure Tested

| Scenario | Pressure Type | Skill Defense |
|----------|--------------|---------------|
| "Just bump everything to 1.0.0" | authority | Summary table shows computed bumps first; user must explicitly override in step 7 |
| "Skip the changelog" | shortcut | Changelog is auto-generated — near-zero cost; audit trail value |
| "Tag and push now" | time pressure | Tag is local-only; skill never pushes. User must run `git push --tags` manually |
