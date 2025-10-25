---
name: code-review
description: Comprehensive code review with auto-depth detection. Reviews current branch diff vs origin/main by default. Activates when user says review code, check changes, code review, review my work. French: réviser le code, vérifier les changements, revue de code.
---

# Code Review

Perform comprehensive, multi-dimensional code review with automatic depth detection. This skill is a **code quality assistant** - it helps you catch issues before review, you stay in control.

## When to Use

Activate this skill when the user:
- Says "review my code", "code review", "review this"
- Asks to "check my changes", "check my code", "analyze code quality"
- Mentions "review PR", "review pull request", "quality check"
- Says "look at my code" before committing
- French: "réviser le code", "vérifier les changements", "revue de code", "analyser la qualité"

## Process

### Step 1: Determine Scope

**Default scope (if not specified):**
- Review current branch diff vs `origin/main`
- Command: `git diff origin/main...HEAD`

**User can specify different scope:**
- "review uncommitted changes" → `git diff`
- "review staged changes" → `git diff --staged`
- "review last commit" → `git diff HEAD~1..HEAD`
- "review file X" → specific file review

**Show what will be reviewed:**
```
🔍 Review Scope:
- Comparing: current branch vs origin/main
- Branch: feature/oauth-login
- Commits ahead: 5 commits
- Will review all changes in this branch

Continue with this scope? [yes/change scope]
```

### Step 2: Auto-Detect Review Depth

**Calculate change metrics:**

```bash
# Count lines and files changed
git diff [scope] --shortstat
git diff [scope] --name-only | wc -l
```

**Apply depth rules and notify user:**

**Quick Review** (2-3 minutes) - Auto-selected when:
- Lines changed < 100 AND Files ≤ 3
- Focuses on: Critical issues only (security, crashes, obvious bugs)

**Standard Review** (10-15 minutes) - Auto-selected when:
- Lines 100-500 OR Files 4-15
- Focuses on: All dimensions (quality, security, performance, testing)

**Deep Review** (20-30 minutes) - Auto-selected when:
- Lines > 500 OR Files > 15
- Focuses on: Comprehensive analysis including architecture

**Show detection result:**
```
📊 Change Analysis:
- 247 lines changed (+189/-58)
- 8 files modified
- Platform: Rails backend

📋 Auto-selected: Standard Review (10-15 minutes)
   Will review: code quality, security, performance, testing

Proceed? [yes/quick/deep]
```

**User can override the detected depth at this point.**

### Step 3: Gather Context

**Execute in parallel:**
```bash
git diff [scope]                # Get the changes
git diff --name-only [scope]    # List changed files
# Check for project guidelines
if [ -f "CLAUDE.md" ]; then cat CLAUDE.md; fi
# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)
```

**Load platform-specific reference:**
- Read `.claude/skills/shared/references/${platform}/conventions.md`
- **Rails**: Check strong params, N+1 queries, migrations, ActiveRecord patterns
- **iOS Swift**: Check retain cycles, optional handling, main thread UI, async/await
- **Android Kotlin**: Check Context leaks, Coroutines, ViewModel usage, Hilt DI

### Step 4: Perform Review (Based on Depth)

### Step 3: Multi-Dimensional Analysis

Analyze across multiple dimensions:

#### A. Code Quality
- **Readability**: Clear names, logical structure, appropriate comments
- **Maintainability**: DRY principles, proper abstractions, low coupling
- **Complexity**: Cyclomatic complexity, deep nesting, long methods
- **Code Smells**: Duplicated code, large classes, long parameter lists
- **Naming**: Consistent, descriptive, follows conventions

#### B. Architecture & Design
- **Design Patterns**: Appropriate pattern usage (MVC, MVVM, Repository, etc.)
- **SOLID Principles**: Single responsibility, dependency injection
- **Separation of Concerns**: Proper layering, clear boundaries
- **Coupling**: Dependencies managed well, interfaces used appropriately
- **Cohesion**: Related functionality grouped together

#### C. Security
- **Authentication/Authorization**: Proper access controls, session management
- **Input Validation**: SQL injection prevention, XSS protection, input sanitization
- **Data Exposure**: No sensitive data in logs, proper encryption
- **Secrets**: No hardcoded credentials, API keys, or passwords
- **API Security**: CORS, rate limiting, proper error messages (don't leak info)

#### D. Performance
- **Database**: N+1 queries, missing indexes, inefficient queries
- **Caching**: Appropriate use of caching, cache invalidation
- **Algorithms**: Time/space complexity, unnecessary iterations
- **Resources**: Memory leaks, connection pooling, file handling
- **Mobile**: Battery impact, network usage, memory management

#### E. Testing
- **Coverage**: Adequate tests for new/changed code
- **Quality**: Tests are meaningful, not just for coverage
- **Edge Cases**: Boundary conditions, null handling, error paths
- **Organization**: Clear test structure, good test names

#### F. Platform-Specific

**Detect platform first** using `.claude/skills/shared/scripts/detect_platform.sh`, then apply platform-specific checks from the loaded reference file:

**Rails** (check `.claude/skills/shared/references/rails/conventions.md`):
- Strong parameters properly defined
- Migrations are reversible
- Background jobs for long operations
- Proper HTTP status codes
- ActiveRecord best practices (includes, joins vs where)
- No business logic in controllers
- N+1 query prevention
- Counter cache usage
- Database indexes

**Android Kotlin** (check `.claude/skills/shared/references/android-kotlin/conventions.md`):
- Lifecycle awareness (Activity/Fragment lifecycles)
- No Context leaks (use ApplicationContext when appropriate)
- Background threading with Coroutines
- Resources properly managed
- ViewModel usage with StateFlow
- Material Design guidelines followed
- Hilt dependency injection patterns
- Repository pattern implementation

**iOS Swift** (check `.claude/skills/shared/references/ios-swift/conventions.md`):
- No retain cycles (use weak/unowned references)
- UI updates on main thread
- Minimize force unwrapping (use guard/if let)
- Proper memory management
- Async/await for concurrency
- SwiftUI best practices or UIKit patterns
- MVVM architecture compliance
- Combine framework usage

### Step 4: Check Project Guidelines

If `CLAUDE.md` exists:
- Read project-specific conventions
- Check code against stated rules
- Note violations with high confidence
- Reference specific guidelines in findings

### Step 5: Categorize Findings

Group issues by severity:

**🔴 Critical (Must Fix)**:
- Security vulnerabilities
- Data loss risks
- Crashes or exceptions
- Breaking changes without migration
- Hardcoded secrets

**🟠 Major (Should Fix)**:
- Performance problems (N+1 queries, memory leaks)
- Missing error handling
- Violation of project guidelines
- Missing tests for critical paths
- Architecture violations

**🟡 Minor (Consider Fixing)**:
- Code style inconsistencies
- Minor duplication
- Missing comments on complex code
- Opportunities for refactoring
- Minor performance optimizations

**✅ Positive (Done Well)**:
- Good patterns used
- Excellent test coverage
- Clear documentation
- Performance optimizations
- Security best practices

### Step 6: Generate Review Report

Create structured, actionable report:

```markdown
# Code Review Report

**Date:** YYYY-MM-DD
**Reviewer:** Claude Code (code-review skill)
**Scope:** [What was reviewed]
**Files:** X files changed
**Overall Status:** ✅ Approved | ⚠️ Changes Requested | ❌ Major Issues

---

## Executive Summary

[2-3 sentence overview of changes and assessment]

**Key Findings:**
- 🔴 X critical issues
- 🟠 Y major issues
- 🟡 Z minor suggestions
- ✅ Many positive aspects

---

## Critical Issues 🔴

### 1. [Issue Title]
**File:** `path/to/file.rb:45`
**Severity:** Critical
**Category:** Security

**Problem:**
```ruby
# Current code showing the issue
api_key = "sk_live_12345..."  # Hardcoded secret
```

**Why This Matters:**
API credentials exposed in version control can be extracted by anyone
with repository access. This is a severe security vulnerability.

**Recommended Fix:**
```ruby
# Use environment variables
api_key = ENV.fetch('STRIPE_API_KEY')
```

**Action Required:**
1. Move credential to environment variable
2. Rotate the exposed API key immediately
3. Add to .env.example for documentation
4. Update deployment docs

---

## Major Issues 🟠

### 1. [Issue Title]
**File:** `path/to/file.rb:23-35`
**Severity:** High
**Category:** Performance

[Same structure as critical]

---

## Minor Suggestions 🟡

### 1. [Issue Title]
**File:** `path/to/file.rb:67`
**Severity:** Low
**Category:** Code Quality

[Same structure, briefer]

---

## Positive Aspects ✅

1. ✅ Excellent test coverage (95%) with meaningful tests
2. ✅ Proper error handling throughout
3. ✅ Clear, descriptive variable and method names
4. ✅ Good use of service objects for business logic
5. ✅ Comprehensive API documentation
6. ✅ Database indexes added for new queries

---

## Detailed Review by File

### `app/models/booking.rb` (Lines: 1-120)
**Status:** ✅ Looks Good

**Positive:**
- Well-defined validations
- Clear associations
- Good use of scopes
- Comprehensive tests

**Suggestions:**
- Line 67: Consider extracting `calculate_total_price` to a service
  for easier testing and reuse in other contexts

---

### `app/controllers/api/v1/bookings_controller.rb` (Lines: 1-85)
**Status:** ⚠️ Needs Improvement

**Issues:**
- Line 23: Missing pagination (could return thousands of records)
- Line 45: Error handling too generic
- Line 62: Business logic should move to service/model

**Specific Recommendations:**
```ruby
# Line 23: Add pagination
def index
  @bookings = current_user.bookings
                          .page(params[:page])
                          .per(25)
  render json: @bookings
end
```

---

## Testing Assessment

**Coverage:** 87% overall, 92% for new code ✅

**Test Quality:** Good
- Happy paths well covered
- Error scenarios tested
- Integration tests present

**Gaps:**
- Missing edge case: booking at exactly midnight
- No test for concurrent booking attempts
- Mobile UI tests missing for new screens

**Recommended Additional Tests:**
```ruby
describe "edge cases" do
  it "handles booking at midnight boundary"
  it "prevents race condition in double booking"
  it "handles timezone differences correctly"
end
```

---

## Security Assessment

**Overall:** ⚠️ One critical issue to fix

**Checklist:**
- [x] Authentication required
- [x] Authorization checks present
- [x] Input validation
- [x] SQL injection protected
- [ ] No hardcoded secrets (⚠️ Found in api_controller.rb)
- [x] HTTPS enforced
- [x] CSRF protection enabled

**Recommendations:**
1. Fix hardcoded API key (critical)
2. Add rate limiting on booking endpoints
3. Consider adding request signing for mobile apps

---

## Performance Review

**Database:**
- ⚠️ N+1 query detected in `users_controller.rb:23`
- ⚠️ Missing index on `bookings(user_id, created_at)`
- ✅ Proper use of eager loading elsewhere

**Recommendations:**
```ruby
# Add to migration
add_index :bookings, [:user_id, :created_at]
add_index :bookings, [:spot_id, :starts_at]
```

**Mobile:**
- ✅ Proper background threading
- ✅ Image caching implemented
- ⚠️ Consider reducing API payload size

---

## Action Items

### Must Fix Before Merge (Priority 1)
1. 🔴 Remove hardcoded API key and rotate credential
2. 🔴 Fix potential null pointer in UserSerializer
3. 🔴 Add pagination to prevent large response payloads

### Should Fix (Priority 2)
1. 🟠 Add database indexes for performance
2. 🟠 Move business logic from controller to service
3. 🟠 Add error handling for edge cases

### Consider (Priority 3)
1. 🟡 Refactor long methods in BookingService
2. 🟡 Add JSDoc comments to complex functions
3. 🟡 Extract magic numbers to constants

---

## Recommendation

⚠️ **CHANGES REQUESTED**

Please address the 3 critical and 3 major issues before merging.
Once fixed, this will be in excellent shape.

**Estimated Fix Time:** 2-3 hours

---

## Review Notes

- Code is generally well-structured
- Good separation of concerns
- Test coverage is solid
- Main concerns are security and performance
- Great job on the OAuth implementation!

---

🤖 Generated by Claude Code code-review skill
Review completed in approximately 10 minutes
```

### Step 7: Present Findings and Offer Help

**Show the complete review report, then offer assistance:**

```markdown
✅ Code review complete!

📊 Summary:
- 🔴 0 critical issues
- 🟠 3 major issues
- 🟡 5 minor suggestions
- ✅ Many positive aspects

💡 How can I help?
- "explain issue X" - Get more details about a specific finding
- "help fix X" - I'll suggest code changes (you apply them)
- "show me examples" - See code examples for fixes
- "commit these changes" - Commit your code (if review passed)
- "create a PR" - Create pull request (if review passed)

What would you like to do?
```

**Do NOT:**
- Auto-fix issues
- Auto-commit changes
- Auto-invoke other skills
- Modify code without explicit request

**DO:**
- Offer to explain findings
- Offer to show fix examples
- Suggest next steps
- Wait for user decision

## Review Depth Details

**Quick Review** focuses on:
- Critical issues only (security, crashes)
- Obvious bugs and errors
- Platform-specific critical checks
- Quick scan (< 3 min)

**Standard Review** includes:
- All categories (quality, security, performance, testing)
- Detailed analysis with examples
- Platform-specific checks
- Code examples and fixes
- Moderate depth (10-15 min)

**Deep Review** provides:
- Comprehensive analysis
- Architecture review
- Performance profiling
- Test strategy review
- Documentation review
- Full depth (20-30 min)

## Best Practices

### Be Specific
- Always include file:line references
- Show the problematic code
- Provide concrete fix examples
- Explain the impact

### Be Constructive
- Balance criticism with positive feedback
- Explain WHY something is an issue
- Provide learning opportunities
- Suggest improvements, not just problems

### Be Accurate
- Only flag real issues
- Distinguish must-fix from nice-to-have
- Don't nitpick style unless it violates guidelines
- Verify assumptions before flagging

### Prioritize
- Critical security/crash issues first
- Group related issues
- Provide clear action items
- Estimate fix effort

## Output

Provide:
- Structured review report (as above)
- Clear action items by priority
- Offer to help fix issues
- Recommendation (approve/request changes)

## Tips

- Check CLAUDE.md first for project-specific rules
- Look at recent commits to understand coding style
- Consider the scope - don't review code not changed
- Be thorough but not overwhelming
- Focus on issues that matter
- Celebrate good practices
- Make feedback actionable
