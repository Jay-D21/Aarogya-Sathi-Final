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

## Step 3 â€” Update Context (Do This Before Committing)

1. Update .context/contributors/dev-{name}.md with session summary
2. If API changed â†’ update .context/api/{relevant}.md
3. If DB changed â†’ update .context/database/schema.md
4. If feature completed â†’ update .context/modules/_overview.md
5. Add entry to .context/progress/changelog.md

## Coding Standards

- All API responses: { success: boolean, data?: T, error?: string }
- No new dependencies without team lead approval
- Every component in its own file
- No hardcoded values â€” use environment variables
- Write comments explaining WHY, not WHAT
- Never remove existing comments