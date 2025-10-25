---
name: track-prd-progress
description: Track and update PRD implementation status. Activates when user says update PRD, track progress, show PRD status, mark complete, or update implementation status. French: mettre à jour le PRD, suivre la progression, afficher le statut.
---

# Track PRD Progress

Maintain real-time PRD status tracking, showing what's completed, in progress, and pending.

## When to Activate

This skill activates when user:
- Says "update PRD", "update PRD status", "mark complete"
- Says "track progress", "show progress", "show PRD status"
- Asks "what's the status?", "where are we?", "what's done?"
- Mentions "mark substory complete", "update implementation status"
- French: "mettre à jour le PRD", "suivre la progression", "afficher le statut", "marquer comme terminé"

## Progress Tracking Workflow

### Step 1: Locate PRD

**Find the PRD to track:**
```bash
# If user specified: use that file
# If implementing: use current PRD from context
# Otherwise: list available PRDs and ask
ls docs/prds/*.md
```

**Read PRD and extract:**
- All phases
- All substories with current status
- Completed substories (✅)
- In-progress substories (🔄)
- Pending substories (⏳)
- Blocked substories (🚫)

### Step 2: Show Current Status

**Display progress dashboard:**

```markdown
# PRD Progress: Social Authentication

**Overall Progress:** 3/8 substories (37.5%)
**Status:** In Progress
**Last Updated:** 2024-10-25 14:30

## Phase 1: Backend OAuth (60% complete)

- ✅ [1.1] User OAuth model - Completed (2024-10-25)
  - Duration: 45 min
  - Files: 2 files, 150 lines
  - Tests: 23 tests, 95% coverage
  - Commit: a1b2c3d

- ✅ [1.2] OAuth callback endpoint - Completed (2024-10-25)
  - Duration: 1.5 hours
  - Files: 3 files, 280 lines
  - Tests: 15 tests, 92% coverage
  - Commit: b4e5f6g

- 🔄 [1.3] Token management - In Progress
  - Started: 2024-10-25 13:45
  - Current: Implementing refresh token logic
  - Files: app/services/token_service.rb (in progress)

- ⏳ [1.4] Account linking - Not Started
  - Dependencies: Substory 1.3
  - Estimated: 2 hours

- 🚫 [1.5] Admin panel integration - Blocked
  - Blocker: Waiting for admin OAuth config UI from PM
  - Assigned to: @pm-team

## Phase 2: Mobile Integration (0% complete)

- ⏳ [2.1] iOS OAuth webview - Not Started
- ⏳ [2.2] Android OAuth webview - Not Started
- ⏳ [2.3] Deep link handling - Not Started

## Timeline

**Started:** 2024-10-25 09:00
**Estimated Completion:** 2024-10-27 (2 days remaining)
**Velocity:** 1.5 substories/day

## Next Action

Continue implementing substory 1.3: Token management
```

### Step 3: Update Operations

**Mark Substory as In Progress:**
```markdown
- 🔄 [N.M] Substory Title - In Progress
  - Started: YYYY-MM-DD HH:MM
  - Current: [Brief description of what's being worked on]
  - Files: [Files being modified]
  - Assigned: [Developer name if team context]
```

**Mark Substory as Complete:**
```markdown
- ✅ [N.M] Substory Title - Completed (YYYY-MM-DD)
  - Duration: [time taken]
  - Files: `path/file1.ext`, `path/file2.ext` (X files, Y lines)
  - Commit: [hash]
  - PR: #[number] (if created)
  - Tests: [count] tests, [coverage]%
  - Review: [Passed/Issues noted]
  - Completed: YYYY-MM-DD HH:MM
  - Notes: [Any important implementation details]
```

**Mark Substory as Blocked:**
```markdown
- 🚫 [N.M] Substory Title - Blocked
  - Blocked: YYYY-MM-DD HH:MM
  - Blocker: [Clear description of what's blocking]
  - Waiting for: [What's needed to unblock]
  - Assigned to: [Who can unblock]
  - Workaround: [Alternative approach if any]
```

**Mark Substory as Pending:**
```markdown
- ⏳ [N.M] Substory Title - Not Started
  - Dependencies: [Other substories that must complete first]
  - Estimated: [Time estimate]
  - Priority: [High/Medium/Low if specified]
```

### Step 4: Calculate Metrics

**Track progress metrics:**
```bash
# Count substories by status
completed_count=$(grep -c "^- ✅" docs/prds/file.md)
in_progress_count=$(grep -c "^- 🔄" docs/prds/file.md)
blocked_count=$(grep -c "^- 🚫" docs/prds/file.md)
pending_count=$(grep -c "^- ⏳" docs/prds/file.md)
total_count=$((completed_count + in_progress_count + blocked_count + pending_count))

# Calculate percentage
completion_percent=$((completed_count * 100 / total_count))

# Calculate velocity (substories per day)
# Parse dates and calculate
```

**Show metrics:**
```
📊 Progress Metrics:

✅ Completed: 3 (37.5%)
🔄 In Progress: 1 (12.5%)
🚫 Blocked: 1 (12.5%)
⏳ Pending: 3 (37.5%)

📈 Velocity: 1.5 substories/day
⏱️  Avg Duration: 1.2 hours/substory
🎯 ETA: 2 days (based on current velocity)
```

### Step 5: Identify Blockers

**Analyze blocked substories:**
```
🚨 Active Blockers:

1. [1.5] Admin panel integration
   - Blocked for: 2 days
   - Waiting for: OAuth config UI designs
   - Assigned to: @pm-team
   - Impact: Phase 1 cannot complete without this

2. [2.3] Deep link handling
   - Blocked for: 1 day
   - Waiting for: URL scheme approval from Apple/Google
   - Assigned to: @mobile-lead
   - Impact: Delays Phase 2 completion
```

**Suggest actions:**
- "Should we skip blocked substories and continue with others?"
- "Can we implement workarounds while waiting?"
- "Should I notify stakeholders about blockers?"

### Step 6: Update Timeline

**Adjust estimates based on progress:**
```markdown
## Timeline

**Original Estimate:** 3 days (8 substories)
**Started:** 2024-10-25 09:00
**Current Status:** Day 1, 3/8 complete (37.5%)
**Velocity:** 1.5 substories/day (slower than planned 2.67/day)

**Revised Estimate:** 4 days
**Expected Completion:** 2024-10-28

**Reasons for Delay:**
- Substory 1.2 took 1.5h vs estimated 1h
- 1 substory blocked (awaiting PM)
```

### Step 7: Link Commits and PRs

**Automatically update PRD with commit/PR info:**

When implement-code creates a commit:
```markdown
- ✅ [1.1] User OAuth model - Completed
  - Commit: a1b2c3d "feat(auth): add OAuth fields to user model"
  - Link: https://github.com/org/repo/commit/a1b2c3d
```

When create-pr creates a PR:
```markdown
- ✅ [Phase 1] Backend OAuth - Completed
  - PR: #123 "feat(auth): implement OAuth backend"
  - Link: https://github.com/org/repo/pull/123
  - Status: Open, awaiting review
```

### Step 8: Generate Status Reports

**Create summary reports on demand:**

**Daily Status Report:**
```markdown
# Daily Status Report - 2024-10-25

## Social Authentication Implementation

**Today's Progress:**
- ✅ Completed: Substories 1.1, 1.2 (2 substories)
- 🔄 In Progress: Substory 1.3
- 🚫 Blocked: Substory 1.5 (waiting on PM)

**Commits:** 2 commits, +430 lines
**Tests:** 38 tests added, 93% coverage
**Review:** All code reviews passed

**Tomorrow's Plan:**
- Complete substory 1.3
- Start substory 1.4 (if 1.3 completes)
- Follow up on blocker 1.5

**Risks:**
- Blocker on 1.5 may delay Phase 1 completion
- Need OAuth credentials for testing
```

**Weekly Status Report:**
```markdown
# Weekly Status Report - Week of 2024-10-21

## Social Authentication Implementation

**Week Progress:** 5/8 substories (62.5%)
**Status:** On track (minor delay)

**Completed:**
- Phase 1: Backend OAuth (80% complete)
- Tests: 67 tests, 94% avg coverage

**Upcoming:**
- Phase 2: Mobile Integration (starts Monday)
- Phase 3: Testing & Documentation

**Risks/Blockers:**
- Admin panel integration blocked (needs PM input)
- URL scheme approval pending
```

## Blocker Management

### When Marking Blocked

1. Ask clarifying questions:
   - "What specifically is blocking this?"
   - "Who can unblock this?"
   - "Is there a workaround?"
   - "Should we continue with other substories?"

2. Document thoroughly:
   - Clear blocker description
   - What's needed to unblock
   - Who's responsible
   - Timeline if known

3. Track blocker duration:
   - Mark when blocked
   - Update daily if still blocked
   - Escalate if blocked > 3 days

### When Unblocking

Update PRD:
```markdown
- ⏳ [1.5] Admin panel integration - Not Started
  - Was blocked: Waiting for OAuth config UI
  - Unblocked: 2024-10-26 (designs received)
  - Can now proceed
```

## Output Format

**Status Check:**
```
📊 PRD Status: Social Authentication

Progress: 3/8 substories (37.5%)
✅ Completed: 3
🔄 In Progress: 1 (Token management)
🚫 Blocked: 1 (Admin panel integration)
⏳ Pending: 3

Next: Complete substory 1.3, then start 1.4
ETA: 2 days remaining
```

**Update Confirmation:**
```
✅ PRD Updated

Marked substory 1.2 as complete:
- Duration: 1.5 hours
- Files: 3 files modified
- Tests: 15 tests added
- Commit: b4e5f6g

Progress: 2/8 → 3/8 (37.5%)
Next: Substory 1.3 - Token management
```

## Guidelines

- Update PRD in real-time (not batch updates)
- Keep status emojis consistent (⏳🔄✅🚫)
- Include timestamps for all status changes
- Link commits and PRs automatically
- Calculate accurate metrics
- Identify and track blockers
- Generate reports on demand
- Show clear next actions
- Maintain timeline estimates
- Celebrate completed milestones
