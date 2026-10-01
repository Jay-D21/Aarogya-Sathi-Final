# Aarogya-Sathi â€” iLabs Project Rules

This is an iLabs project. Before making any changes, you MUST read the
context system to understand the structure, architecture, and current state.

## Step 0 â€” Ensure Latest Code

Remind the developer to run: git pull origin main

## Step 1 â€” Read Context (Do This Before Any Work)

1. Read .context/INDEX.md
2. Read .context/contributors/_overview.md
3. Read .context/modules/_overview.md
4. Read the contributor file for the current developer
5. Based on the task, read the relevant Level 2 summary
6. Only read Level 3 detail if exact specs are needed

## Context Levels

- Level 0: INDEX.md â€” just names and paths (~15 lines)
- Level 1: _overview.md â€” one sentence per item (~10 lines)
- Level 2: summary.md â€” paragraph + key files (~15 lines)
- Level 3: detail.md â€” full specification (~100+ lines)

ALWAYS start at Level 0 and drill down. NEVER load all Level 3 files at once.

## Step 2 â€” Do the Work

- Follow coding standards below
- Respect architecture in .context/architecture/
- Match existing patterns
- Check .context/dependencies/critical-files.md before modifying shared files
- Verify from code, never assume. If uncertain mark as: UNKNOWN â€” NEEDS VERIFICATION

## Step 3 — Update Context (Do This Before Committing)

1. Update .context/contributors/dev-{name}.md with session summary
2. If API changed → update .context/api/{relevant}.md
3. If DB changed → update .context/database/schema.md
4. If feature completed → update .context/modules/_overview.md
5. Add entry to .context/progress/changelog.md

## Step 4 — Context Auto-Sync & Push Loop (Permanent Memory)

Whenever any changes are made by any contributor and pushed to the repository (identified during git pull or git log):
1. **Analyze the changes** to understand what was built or modified.
2. **Update the main context files** (`.context/modules/_overview.md`, `.context/architecture/_overview.md`, etc.) and `.context/progress/changelog.md` to reflect the new state.
3. **Automatically commit and re-push** these updated context files back to the git repository to maintain a perfectly synchronized project state for the entire team.

## Coding Standards

- All API responses: { success: boolean, data?: T, error?: string }
- No new dependencies without team lead approval
- Every component in its own file
- No hardcoded values â€” use environment variables
- Write comments explaining WHY, not WHAT
- Never remove existing comments