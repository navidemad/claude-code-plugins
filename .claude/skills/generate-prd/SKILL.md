---
name: generate-prd
description: Generate adaptive PRDs with codebase exploration. Activates when user says create PRD, plan feature, document requirements, write spec, generate PRD, build requirements. French: créer un PRD, planifier une fonctionnalité, rédiger les exigences, écrire une spec.
---

# Generate Product Requirements Document

Create structured PRDs in `docs/prds/YYYY-MM-DD-feature-name.md` with automatic complexity detection and codebase exploration.

## Activation Context

Use when user requests:
- PRD creation for new features
- Feature planning and documentation
- Requirements gathering
- Implementation roadmap
- French: création de PRD, planification de fonctionnalité, spécification

## Discovery Process

### Phase 0: Detect Complexity and Explore Codebase

**Step 1: Understand Feature Scope**

Ask initial scoping question:
```
"Describe the feature briefly (1-2 sentences):"
```

**Step 2: Auto-Detect Complexity**

Analyze user's description to determine mode:

**QUICK MODE** (triggered by):
- Simple CRUD operations
- Minor UI changes
- Single model/component
- Clear, simple requirements
- Keywords: "simple", "just", "only", "basic"

**FULL MODE** (triggered by):
- Multi-system integrations
- Complex business logic
- Multiple phases/components
- External API integrations
- Keywords: "integrate", "complex", "multi-step", "workflow", "system"

**Inform user:**
```
✨ Detected: [QUICK/FULL] mode PRD
📋 This will be a [lightweight/comprehensive] requirements document

Continue? [yes/change mode]
```

**Step 3: Explore Existing Codebase**

**Before asking detailed questions, understand what exists:**

```bash
# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Load platform reference
# Read .claude/skills/shared/references/${platform}/conventions.md
```

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
```

**For iOS Swift:**
```bash
# Find ViewModels and Views
find . -name "*ViewModel.swift" -o -name "*View.swift"

# Check for service patterns
find . -name "*Service.swift"

# Look for existing navigation
grep -r "coordinator\|router" . --include="*.swift"
```

**For Android Kotlin:**
```bash
# Find existing architecture
ls -R app/src/main/java/*/{data,domain,presentation}/

# Check ViewModels
find . -name "*ViewModel.kt"

# Look for repositories
find . -name "*Repository.kt"
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

Will follow these established patterns.
```

### Phase 1: Requirements Gathering

**Adapt questions based on mode:**

**QUICK MODE** - Ask only core questions (5-7 questions):

1. **What does it do?** (Core functionality)
2. **Who uses it?** (Target users)
3. **What changes?** (New vs modification of existing)
4. **What's the main user flow?** (Single primary flow)
5. **How do we know it works?** (Success criteria)
6. **Any dependencies?** (Required features/services)
7. **What's out of scope?** (Explicit exclusions)

**FULL MODE** - Ask comprehensive questions (15-20 questions):

**Feature Overview:**
- Core functionality and purpose
- Problem being solved in detail
- Target users and their specific needs
- Success metrics and KPIs

**Scope Definition:**
- New feature vs enhancement
- Platforms/systems affected (already detected)
- Dependencies on existing features
- Integration points
- Explicitly out of scope items

**User Experience:**
- Multiple user flows (happy path + alternatives)
- UI/UX requirements and mockups
- Edge case handling
- Error scenarios and recovery
- Accessibility requirements

**Technical Requirements:**
- Architecture constraints
- Data models needed (detailed schema)
- API/interface requirements (full specs)
- External integrations
- Authentication/authorization approach
- Performance requirements (specific metrics)
- Scalability considerations
- Security requirements

**Success Criteria:**
- Measurable acceptance criteria per substory
- Key performance indicators
- Definition of done
- Rollout strategy

### Phase 2: Document Generation

Create PRD with this structure:

```markdown
# [Feature Name]

**Created:** YYYY-MM-DD
**Status:** Planning
**Platforms:** [Detected from context: Web/Backend/Mobile/etc.]

## Overview

### Problem Statement
[Clear articulation of problem]

### Solution
[High-level solution description]

### Users
[Target users and use cases]

### Success Criteria
- [Measurable criteria]
- [Key metrics]

## Requirements

### Functional
1. [Requirement with clear scope]

### Non-Functional
- Performance: [specific requirements]
- Security: [requirements]
- Scalability: [requirements]

### Platform-Specific

[Adapt sections based on detected platforms]

#### Backend/API
- Endpoints/interfaces needed
- Data models/schemas
- Background processes
- External services

#### Frontend/Web
- UI components
- State management
- API integration
- Client-side storage

#### Mobile
- Platform-specific components
- API client changes
- Local persistence
- Platform permissions

## Implementation Phases

### Phase [N]: [Phase Name]
**Goal:** [Phase objective]
**Estimate:** [duration]

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

### Phase 3: Validation

After document creation:
- Review completeness with user
- Confirm acceptance criteria are measurable
- Verify technical specifications are sufficient
- Identify any unclear areas

## Output

Provide user with:
- PRD file path
- Summary of phases and substories
- Confirmation of next steps
- Any items needing clarification

## Guidelines

- **Detect platform first**: Run `.claude/skills/shared/scripts/detect_platform.sh`
- **Load platform reference**: Read `.claude/skills/shared/references/{platform}/conventions.md`
- **Use platform-specific terminology**:
  - Rails: models, controllers, services, migrations, jobs
  - iOS Swift: ViewControllers, ViewModels, Views, Services, coordinators
  - Android Kotlin: Activities, Fragments, ViewModels, Repositories, UseCases
- Adjust detail level based on feature complexity
- Break complex features into smaller substories
- Ensure acceptance criteria are testable
- Include realistic time estimates
- Document assumptions explicitly
- Reference platform patterns from loaded conventions
