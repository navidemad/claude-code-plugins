# plan-prd UX Improvement

## Issue

The skill was inconsistent in how it asked questions:
- Sometimes used interactive AskUserQuestion tool with navigable options ✅
- Sometimes just output questions as plain text ❌

**User wanted**: Consistent interactive UX with navigable options

## Solution

Updated `SKILL.md` to explicitly require and demonstrate using AskUserQuestion tool.

## Changes Made

### 1. Added Explicit UX Instructions (Phase 1)

**New section at start of Phase 1:**
```markdown
**CRITICAL: Always use AskUserQuestion tool for interactive UX**

Do NOT just output questions as text. Use the `AskUserQuestion` tool to create
an interactive experience where users can navigate through options.
```

### 2. Provided Concrete Examples

**For CORE PRD Mode:**
- 4 question groups with full AskUserQuestion examples
- Problem & Context group
- Minimal Scope group
- Success & Boundaries group
- Technical Constraints group (conditional)

**For EXPANSION PRD Mode:**
- 4 question groups with full AskUserQuestion examples
- Expansion Goal group
- Data & Integration group
- Pattern Consistency group (references loaded patterns)
- Success & Scope group

### 3. Good vs Bad UX Examples

**Good UX:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What problem does this feature solve?",
      header: "Problem",
      options: [
        {label: "User pain point", description: "Solving a specific user frustration"},
        {label: "Business need", description: "Meeting a business requirement"},
        {label: "Technical debt", description: "Improving existing system"}
      ],
      multiSelect: false
    }
  ]
)
```

**Bad UX:**
```
Just outputting: "What problem does this solve? Who is this for? What's the scope?"
```

### 4. Updated Guidelines

Added first rule in Guidelines section:
```markdown
**ALWAYS use AskUserQuestion tool** - For interactive UX with navigable
options (see Phase 1 for examples)
```

## File Changes

- `skills/plan-prd/SKILL.md` - Updated from 3,252 to 3,823 words (+571 words, +18%)

**Reason for increase**: Added concrete AskUserQuestion examples for each question group

## Impact

### Context Usage
- Before: 3,252 words ≈ ~4,000 tokens
- After: 3,823 words ≈ ~4,800 tokens
- Increase: ~800 tokens (~0.4% of 200K budget)

**Still very affordable** - necessary for consistent UX

### User Experience

**Before (inconsistent):**
- Sometimes: Interactive questions with options ✅
- Sometimes: Plain text list of questions ❌
- User confused by inconsistency

**After (consistent):**
- Always: Interactive questions with AskUserQuestion tool ✅
- Clear examples of how to structure each question
- Navigable options for every question
- Better UX, more predictable behavior

## Key Features of Updated Questions

### Question Grouping
Questions organized in logical groups of 2-3 related questions:
- Group 1: Problem & Context
- Group 2: Minimal Scope
- Group 3: Success & Boundaries
- Group 4: Technical Constraints (conditional)

### Option Design
Each question has 2-4 clear options:
- Short labels (e.g., "User pain point")
- Descriptive text (e.g., "Solving a specific user frustration")
- "Other" option automatically provided by tool for custom input

### multiSelect Support
Some questions allow multiple selections:
```javascript
{
  question: "How will we measure success?",
  multiSelect: true,  // User can select multiple options
  options: [...]
}
```

### Pattern References (Expansion Mode)
Questions reference loaded patterns from core:
```javascript
{
  question: "I see the core uses [Pattern X] for [Purpose].
             Should this expansion follow the same pattern?",
  options: [
    {label: "Yes, use same", description: "Keep consistency with core"},
    {label: "Slight variation", description: "Similar but adapted"},
    ...
  ]
}
```

## Testing

To verify the improvement works:

1. **Start planning a PRD**: "plan a feature for hello world"
2. **Verify Phase 0**: Should show CLAUDE.md validation
3. **Verify Phase 1 - PRD Type**: Should use AskUserQuestion with 3 options (Core/Expansion/Task)
4. **Verify requirements gathering**: Should use AskUserQuestion for ALL questions
5. **Check consistency**: Every question should have navigable options

**Expected behavior**: No plain text questions - all interactive with AskUserQuestion

## Example Flow

```
User: "plan a new feature for user login"

Skill: [Shows CLAUDE.md validation]
✅ CLAUDE.md found
📋 Ready to plan PRD

Skill: [Uses AskUserQuestion]
Is this:
1. 🌱 A new core feature
2. 🔧 An expansion of existing feature
3. ⚡ A task-based change

User: Selects "1"

Skill: [Uses AskUserQuestion for Problem & Context]
Question 1: What problem does this feature solve?
□ User pain point
□ Business need
□ Technical improvement

Question 2: Who will use this feature?
□ End users
□ Admin users
□ Developers

User: Selects options

Skill: [Uses AskUserQuestion for Minimal Scope]
...continues with interactive questions...
```

## Benefits

1. **Consistent UX** - Always uses interactive questions
2. **Clear examples** - Skill knows exactly how to structure questions
3. **Better navigation** - Users can select options instead of typing
4. **Faster workflow** - Less typing, clearer choices
5. **Reduced ambiguity** - Options clarify what's being asked

## Trade-offs

**Increased file size**: +571 words
- From 3,252 to 3,823 words
- Worth it for consistent UX
- Still only ~0.4% increase in context usage

**More detailed instructions**: More for skill to process
- But provides clear examples
- Reduces inconsistent behavior
- Better results justify the increase

## Status

✅ Implementation complete
✅ Examples provided for all question groups
✅ Guidelines updated
✅ Ready for testing

## Date

2025-10-26
