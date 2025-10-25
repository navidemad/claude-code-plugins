---
name: generate-prd
description: Generate comprehensive PRDs with phases and substories. Activates when user says create PRD, plan feature, document requirements, write requirements, generate PRD, or spec out feature.
---

# Generate Product Requirements Document

Create structured PRDs in `docs/prds/YYYY-MM-DD-feature-name.md` through interactive discovery and comprehensive documentation.

## Activation Context

Use when user requests:
- PRD creation for new features
- Feature planning and documentation
- Requirements gathering
- Implementation roadmap

## Discovery Process

### Phase 1: Requirements Gathering

**FIRST: Detect platform and load reference (cached for session):**
```bash
# Detect once per session and cache result
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Load platform-specific reference
# Read .claude/skills/shared/references/${platform}/conventions.md
```

**Use reference file to:**
- Use platform-specific terminology in questions
- Tailor PRD structure to platform patterns
- Include platform-appropriate technical sections

Ask targeted questions to understand:

**Feature Overview**
- Core functionality and purpose
- Problem being solved
- Target users and their needs
- Success metrics

**Scope Definition**
- New feature vs enhancement
- Platforms/systems affected (already detected)
- Dependencies on existing features
- Explicitly out of scope items

**User Experience**
- Primary user flows
- UI/UX requirements
- Edge case handling
- Error scenarios

**Technical Requirements**
- Architecture constraints
- Data models needed
- API/interface requirements
- External integrations
- Authentication/authorization
- Performance requirements

**Success Criteria**
- Measurable acceptance criteria
- Key performance indicators
- Definition of done

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
