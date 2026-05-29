Let me check your current Git remote setup first:

Ran command: `git remote -v`
Ran command: `git branch -a`

You only have your fork as `origin`. Here's the one-time setup and the ongoing workflow:

### 1. Add the upstream remote (one-time)

Ran command: `git remote add upstream https://github.com/googleanalytics/google-analytics-mcp.git`

Done. Now whenever you want to sync, the workflow is:

### 2. Sync with upstream (repeat as needed)

```bash
# Fetch latest from upstream
git fetch upstream

# Rebase your changes on top of upstream's main
git rebase upstream/main

# Push to your fork
git push origin main --force-with-lease
```

**Why `rebase` instead of `merge`?** Rebase replays your Docker commits on top of upstream's latest, keeping a clean linear history. Your Docker files (`Dockerfile`, `.dockerignore`, `docker-compose.yml`) don't exist upstream, so there should be **zero conflicts** in most cases.

If a conflict ever does happen (e.g. upstream modifies `.gitignore` or `README.md` where we also made changes), Git will pause and let you resolve it — just pick the parts you want from both sides, then `git rebase --continue`.

### Quick reference

| What | Command |
|---|---|
| Fetch upstream | `git fetch upstream` |
| Sync (rebase) | `git rebase upstream/main` |
| Push to your fork | `git push origin main --force-with-lease` |
| If conflict, abort | `git rebase --abort` |
| If conflict, fix & continue | *edit files* → `git add .` → `git rebase --continue` |