---
name: generate-prd
description: Generate core or expansion PRDs with codebase exploration using "land then expand" approach. Activates when user says create PRD, plan feature, document requirements, write spec, generate PRD, build requirements. French: créer un PRD, planifier une fonctionnalité, rédiger les exigences, écrire une spec.
---

# Generate Product Requirements Document

Create structured PRDs using the **"land then expand"** approach: minimal core first, focused expansions later.

## Philosophy: Land Then Expand

Modern Claude models work best when they establish patterns first, then layer complexity. This skill creates:

1. **Core PRDs**: Minimal foundation with essential fields only (2-4 substories max)
2. **Expansion PRDs**: Focused enhancements building on completed core

**Why**: Large comprehensive PRDs lead to incorrect assumptions, token inefficiency, and inconsistent results.

## Activation Context

Use when user requests:
- PRD creation for new features
- Feature planning and documentation
- Requirements gathering
- Implementation roadmap
- French: création de PRD, planification de fonctionnalité, spécification

## Discovery Process

### Phase 0: Determine PRD Type and Explore Codebase

**Step 1: Ask PRD Type**

**CRITICAL**: Ask user to determine if this is a core or expansion PRD:

```
Is this:
1. 🌱 A new core feature (minimal foundation to establish patterns)
2. 🔧 An expansion of existing feature (builds on completed core)

Choose [1/2]:
```

**If user chooses "1 - Core Feature":**
- Create minimal foundation PRD
- Max 2-4 substories in single phase
- Essential fields only (example: invoice with just number, date, amount)
- File: `docs/prds/YYYY-MM-DD-{feature}-core.md`
- Goal: Establish patterns and working code, NOT completeness

**If user chooses "2 - Expansion":**
- Ask: "Which core feature does this expand?" (or check `docs/prds/` for existing core PRDs)
- Create focused expansion PRD building on core
- File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`
- Examples: `-customer-details.md`, `-line-items.md`, `-payment-logic.md`
- Goal: Add one focused aspect using established patterns

**Step 2: Understand Feature Scope**

Ask scoping question:
```
"Describe the [core feature/expansion] briefly (1-2 sentences):"
```

**For Core PRDs - Enforce Minimalism:**
If user describes complex multi-part feature, push back:
```
🌱 Core PRD Mode: Let's start with the absolute minimum.

You described: [user's description]

What's the simplest version with just essential fields?
Example: If building invoices, start with just number, date, amount.
Everything else (customers, line items, tax) comes later as expansions.

Simplest core version:
```

**For Expansion PRDs:**
Ask specifically what this expansion adds to the core.

**Step 3: Explore Existing Codebase**

**Before asking detailed questions, understand what exists:**

```bash
# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Load platform reference
# Read .claude/skills/shared/references/${platform}/conventions.md
```

**For Core PRDs:**
Explore to understand project patterns and conventions.

**For Expansion PRDs (CRITICAL):**
- Find and read the core PRD file
- Identify which files were created in core implementation
- Read those core implementation files to understand established patterns
- Use these patterns as the foundation for expansion

**Explore relevant areas:**

**For Rails:**
```bash
# Find similar features
ls app/models/ app/controllers/ app/services/

# Check for related models
grep -r "class.*Model" app/models/

# Look for authentication/authorization patterns
ls app/policies/ app/controllers/concerns/

# Check existing API structure
grep -r "namespace.*api" config/routes.rb

# For expansions: Read core implementation files
# Example: cat app/models/invoice.rb app/controllers/invoices_controller.rb
```

**For iOS Swift:**
```bash
# Find ViewModels and Views
find . -name "*ViewModel.swift" -o -name "*View.swift"

# Check for service patterns
find . -name "*Service.swift"

# Look for existing navigation
grep -r "coordinator\|router" . --include="*.swift"

# For expansions: Read core implementation files
```

**For Android Kotlin:**
```bash
# Find existing architecture
ls -R app/src/main/java/*/{data,domain,presentation}/

# Check ViewModels
find . -name "*ViewModel.kt"

# Look for repositories
find . -name "*Repository.kt"

# For expansions: Read core implementation files
```

**Document findings:**
```
🔍 Codebase Analysis:
- Found similar feature: OAuth login in app/services/auth/
- Existing pattern: Service objects for business logic
- Database: PostgreSQL with ActiveRecord
- API: RESTful endpoints under /api/v1/
- Testing: RSpec with FactoryBot
- Authentication: Devise + JWT

[For expansions: Also document core implementation patterns found]

Will follow these established patterns.
```

### Phase 1: Requirements Gathering

**Adapt questions based on PRD type:**

**CORE PRD MODE** - Ask minimal essential questions (5-7 questions):

**Focus on absolute essentials only:**

1. **What are the essential fields/data?** (Minimum viable data model)
2. **Who uses it?** (Target users)
3. **What's the single main user flow?** (One primary happy path only)
4. **How do we know it works?** (Basic success criteria)
5. **Any critical dependencies?** (Required features/services)
6. **What's explicitly out of scope for the core?** (Everything else becomes expansions)

**Important**: If answers suggest complexity, remind user that core is minimal and suggest moving complexity to expansions.

**EXPANSION PRD MODE** - Ask focused questions about the expansion (8-12 questions):

**Context Questions:**
1. **What does this expansion add to the core?** (Specific enhancement)
2. **Which core PRD does this build on?** (Reference existing core)
3. **What core patterns should we follow?** (Based on implemented core files)

**Expansion Scope:**
4. **What new data/fields are needed?** (Additions to core data model)
5. **What user flows does this enable/enhance?** (New or modified flows)
6. **Integration points with core?** (How it connects to existing code)
7. **How do we know it works?** (Acceptance criteria)
8. **Any new dependencies?** (External services, libraries)
9. **Performance considerations?** (If applicable)
10. **Security considerations?** (Auth/validation needs)
11. **What's out of scope for this expansion?** (May become another expansion)

**Important**: Expansion PRDs should be focused on ONE aspect (e.g., customer details OR line items, not both)

### Phase 2: Document Generation

**CRITICAL**: Structure differs for core vs expansion PRDs.

#### Core PRD Structure

File: `docs/prds/YYYY-MM-DD-{feature}-core.md`

```markdown
# [Feature Name] - Core

**Type:** Core Feature
**Created:** YYYY-MM-DD
**Status:** Planning
**Platforms:** [Detected from context]

## Overview

### Problem Statement
[Clear articulation of problem]

### Core Solution
[Minimal viable solution - essential fields/functionality ONLY]

### Users
[Target users]

### Success Criteria
- [Basic measurable criteria]

## Core Requirements

### Essential Data/Fields
[ONLY the minimum viable fields - example: invoice number, date, amount]

### Core User Flow
[Single primary happy path only]

### Out of Scope (Future Expansions)
[List everything NOT in core - these become expansion PRDs]
Examples:
- Customer details → expansion PRD
- Line items → expansion PRD
- Tax calculations → expansion PRD

## Implementation

**RULE**: Maximum ONE phase with 2-4 substories

### Phase 1: Core Foundation
**Goal:** Establish minimal working feature with essential patterns

#### Substory 1.1: [Minimal Model/Component]
**Description:** [Create basic entity with essential fields only]

**Acceptance Criteria:**
- [ ] [Essential field 1] works
- [ ] [Essential field 2] works
- [ ] Basic CRUD operations

**Status:** ⏳ Not Started

#### Substory 1.2: [Basic Interface/API]
**Description:** [Simple create/read operations]

**Acceptance Criteria:**
- [ ] Can create with essential fields
- [ ] Can retrieve

**Status:** ⏳ Not Started

[2-4 substories maximum]

## Platform-Specific Notes
[Minimal platform-specific details for core only]

## Next Expansions
After core is complete, consider these expansion PRDs:
1. [Expansion 1 name]
2. [Expansion 2 name]
3. [Expansion 3 name]
```

#### Expansion PRD Structure

File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

```markdown
# [Feature Name] - [Expansion Name]

**Type:** Expansion
**Builds On:** [Link to core PRD: docs/prds/YYYY-MM-DD-{feature}-core.md]
**Created:** YYYY-MM-DD
**Status:** Planning
**Platforms:** [Same as core]

## Overview

### What This Expansion Adds
[Specific enhancement to core]

### Core Implementation Reference
**Files created in core:**
- [file path 1]
- [file path 2]

**Patterns established in core:**
- [pattern 1 - e.g., "Service objects for business logic"]
- [pattern 2 - e.g., "RESTful API under /api/v1/"]

### Success Criteria
- [Measurable criteria for this expansion]

## Expansion Requirements

### New Data/Fields
[What's added to the core data model]

### Enhanced/New User Flows
[How this changes or adds to core flows]

### Integration with Core
[How this connects to existing core implementation]

## Implementation

### Phase 1: [Expansion Name]
**Goal:** [Expansion objective]

#### Substory 1.1: [Enhancement 1]
**Description:** [Building on core patterns]

**Core Files to Modify:**
- [existing file from core]

**Core Patterns to Follow:**
- [reference established patterns]

**Acceptance Criteria:**
- [ ] [Criterion 1]

**Status:** ⏳ Not Started

[Add substories as needed for focused expansion]

#### Substory [N.M]: [Title]
**Description:** [Implementation scope]

**Acceptance Criteria:**
- [ ] [Testable criterion]
- [ ] [Testable criterion]

**Technical Notes:**
- [Implementation approach]
- [Files/modules to modify]
- [Dependencies]

**Status:** ⏳ Not Started

## User Flows

### [Flow Name]
1. [User action] → [System response]
2. [User action] → [System response]

**Edge Cases:**
- [Scenario]: [Handling]

## API/Interface Specifications

### [METHOD] /api/v1/[resource] or [Interface/Function Signature]
**Purpose:** [Description]

**Request/Input:**
```
[Format appropriate to platform]
```

**Response/Output:**
```
[Format appropriate to platform]
```

**Errors:**
- [Error scenarios and handling]

## Data Schema

### [Entity/Model/Table Name]
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | [type] | PK | Primary key |

**Indexes/Keys:**
- [Optimization details]

**Relationships:**
- [Associations between entities]

## Testing Strategy

### Unit Tests
- [Component/module testing]

### Integration Tests
- [System integration scenarios]

### End-to-End Tests
- [Critical user flows]

### Platform-Specific Tests
- [UI tests, API tests, etc.]

## Security Considerations

- [Authentication/authorization requirements]
- [Data protection needs]
- [Input validation]
- [Security best practices]

## Performance Considerations

- [Load expectations]
- [Optimization strategy]
- [Caching approach]
- [Resource management]

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| [Risk] | [H/M/L] | [H/M/L] | [Strategy] |

## Dependencies

### Internal
- [Feature dependencies]

### External
- [Third-party services]
- [Platform requirements]

## Timeline

| Phase | Duration | Target Date | Status |
|-------|----------|-------------|--------|
| Phase 1 | [time] | YYYY-MM-DD | ⏳ |

## Implementation Status

*Updated automatically by implement-prd skill*

### Phase 1: [Name]
- ⏳ [Substory 1.1] Not Started
- ⏳ [Substory 1.2] Not Started

## Changelog
- YYYY-MM-DD: PRD created
```

### Phase 3: Validation and Next Steps

**After Core PRD creation:**
- Verify it's truly minimal (2-4 substories max)
- Confirm essential fields only
- Suggest expansion PRDs for excluded features
- Output message:
```
✅ Core PRD created: docs/prds/YYYY-MM-DD-{feature}-core.md

📋 Core includes: [brief summary]
🚫 Out of scope (future expansions): [list]

💡 Next steps:
1. "Implement the core PRD" - Build minimal foundation
2. After core is complete, create expansion PRDs for: [list]
```

**After Expansion PRD creation:**
- Verify it builds on completed core
- Confirm focused on ONE aspect
- Reference core implementation patterns
- Output message:
```
✅ Expansion PRD created: docs/prds/YYYY-MM-DD-{feature}-{expansion}.md

🔧 Expands: {core feature name}
📋 Adds: [brief summary]
🎯 Follows core patterns from: [core files]

💡 Next: "Implement this expansion PRD"
```

## Guidelines

**Critical Rules:**
- **ALWAYS ask core vs expansion first** - This determines everything
- **For Core: Enforce minimalism** - Push back on complexity, max 2-4 substories
- **For Expansion: Load core context** - Read core PRD and implementation files
- **Naming convention**:
  - Core: `docs/prds/YYYY-MM-DD-{feature}-core.md`
  - Expansion: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

**Platform Detection:**
- Run `.claude/skills/shared/scripts/detect_platform.sh`
- Read `.claude/skills/shared/references/{platform}/conventions.md`
- Use platform-specific terminology:
  - Rails: models, controllers, services, migrations, jobs
  - iOS Swift: ViewControllers, ViewModels, Views, Services, coordinators
  - Android Kotlin: Activities, Fragments, ViewModels, Repositories, UseCases

**Quality Checks:**
- Ensure acceptance criteria are testable
- Document assumptions explicitly
- Reference platform patterns from loaded conventions
- For expansions: explicitly reference core implementation patterns
