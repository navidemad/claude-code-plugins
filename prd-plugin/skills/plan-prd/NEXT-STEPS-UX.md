# Next Steps UX Enhancement

## Issue

At the end of the plan-prd workflow, the skill showed "Next steps" as plain text output instead of using the interactive AskUserQuestion tool.

**User wanted**: Consistent interactive UX with navigable options at the end of PRD creation, including a third option for free text input.

## Solution

Updated Phase 4 "Validation and Next Steps" section in `SKILL.md` to use AskUserQuestion tool for all three PRD types.

## Changes Made

### 1. Core PRD Completion (lines 795-819)

**Before:**
```markdown
💡 Next steps:
1. "implement" - Build core foundation with auto-testing and review
2. After core is complete, use "plan" again for expansions:
   - Customer details expansion
   - Line items expansion
   - [etc]
```

**After:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Core PRD?",
      header: "Next Step",
      options: [
        {
          label: "Implement now",
          description: "Start building core foundation with auto-testing and review"
        },
        {
          label: "Plan expansion",
          description: "Create expansion PRD for: Customer details, Line items, etc."
        }
      ],
      multiSelect: false
    }
  ]
)
```

### 2. Expansion PRD Completion (lines 839-863)

**Before:**
```markdown
💡 Next: "implement" to build this expansion following core patterns
```

**After:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Expansion PRD?",
      header: "Next Step",
      options: [
        {
          label: "Implement now",
          description: "Build this expansion following core patterns with auto-testing"
        },
        {
          label: "Plan another expansion",
          description: "Create additional expansion PRD for other features"
        }
      ],
      multiSelect: false
    }
  ]
)
```

### 3. Task PRD Completion (lines 879-903)

**Before:**
```markdown
💡 Next: "implement" to execute this task checklist
```

**After:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Task PRD?",
      header: "Next Step",
      options: [
        {
          label: "Execute task now",
          description: "Implement this task checklist with validation and rollback plan"
        },
        {
          label: "Plan another task",
          description: "Create additional task-based PRD for other changes"
        }
      ],
      multiSelect: false
    }
  ]
)
```

## Key Features

### Automatic "Other" Option
The AskUserQuestion tool **automatically provides an "Other" option** that allows free text input. This satisfies the user's requirement for "a third option with free text" without needing to explicitly define it.

**User will see:**
1. Implement now
2. Plan expansion/another/task
3. **Other** (automatically added - allows free text input)

### Consistent UX
All three PRD completion scenarios now use the same interactive pattern:
- ✅ Navigable options instead of text
- ✅ Clear descriptions for each option
- ✅ Free text input available via automatic "Other" option
- ✅ Matches UX pattern used throughout plan-prd skill

### Context-Aware Options
Each PRD type has tailored options:
- **Core PRD**: Implement or plan expansions
- **Expansion PRD**: Implement or plan more expansions
- **Task PRD**: Execute or plan more tasks

## File Changes

- `skills/plan-prd/SKILL.md` - Updated from 3,823 to ~3,970 words (+~150 words, +4%)

**Reason for increase**: Added AskUserQuestion examples for all three completion scenarios

## Impact

### Context Usage
- Before: 3,823 words ≈ ~4,800 tokens
- After: ~3,970 words ≈ ~5,000 tokens
- Increase: ~200 tokens (~0.1% of 200K budget)

**Very affordable** - completes the consistent UX improvement

### User Experience

**Before:**
- Core: Text list of next steps ❌
- Expansion: Single text line ❌
- Task: Single text line ❌
- User needs to type commands manually

**After:**
- Core: Interactive question with 2 options + Other ✅
- Expansion: Interactive question with 2 options + Other ✅
- Task: Interactive question with 2 options + Other ✅
- User can navigate and select options
- Free text available via automatic "Other" option

## Benefits

1. **Consistent UX throughout** - From start to finish, all interactions use AskUserQuestion
2. **Reduced typing** - Users select options instead of typing commands
3. **Clear choices** - Descriptions help users understand what each option does
4. **Free text option** - "Other" automatically provided for custom input
5. **Faster workflow** - Navigation is quicker than typing

## Example Flow

```
Skill: [Shows PRD completion summary]
✅ Core PRD created: .claude/prds/2025-10-26-user-auth-core.md
📋 Context file: .claude/prds/context/2025-10-26-user-auth-core.json

📋 Core includes: Basic login/logout, session management
🚫 Out of scope (future expansions): OAuth, 2FA, password reset

💡 What would you like to do next?

Skill: [Uses AskUserQuestion]
What would you like to do next with this Core PRD?
□ Implement now - Start building core foundation with auto-testing and review
□ Plan expansion - Create expansion PRD for: Customer details, Line items, etc.
□ Other

User: Selects "Implement now"

Skill: Great! Let me trigger the code-prd skill to implement this PRD...
[Launches code-prd skill]
```

## Testing

To verify this enhancement:

1. **Complete a Core PRD**: "plan a feature for user authentication"
2. **Verify end UX**: Should show AskUserQuestion with 2 options + Other
3. **Complete an Expansion PRD**: "plan expansion for OAuth"
4. **Verify end UX**: Should show AskUserQuestion with 2 options + Other
5. **Complete a Task PRD**: "plan task for database migration"
6. **Verify end UX**: Should show AskUserQuestion with 2 options + Other
7. **Test "Other" option**: Select "Other" and provide free text input

**Expected behavior**: All three PRD types show interactive options at completion

## Status

✅ Implementation complete
✅ All three PRD types updated
✅ Consistent with rest of skill's UX
✅ Free text option automatically provided
✅ Ready for testing

## Date

2025-10-26
