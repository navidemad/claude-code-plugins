# Skills Documentation

## Platform Support

**Automatically detects and adapts to:**

### Supported Platforms
- **Ruby on Rails** - Models, controllers, services, migrations, ActiveRecord patterns, RSpec/Minitest
- **iOS/Swift** - MVVM architecture, SwiftUI/UIKit, ViewModels, Combine, async/await
- **Android/Kotlin** - Clean Architecture, MVVM, Coroutines, Hilt DI, Jetpack Compose

### Detection Method
Skills automatically detect your platform by analyzing project files:
- **Rails**: Presence of `Gemfile` with `gem "rails"`
- **iOS Swift**: `.xcodeproj` folder, `Podfile`, or `Package.swift`
- **Android Kotlin**: `gradle.properties` file at project root

Once detected, skills automatically load platform-specific conventions and best practices from reference files, ensuring code generation follows your platform's standards.

## Skills in Detail

<details>
<summary><strong><¯ generate-prd</strong> - Create adaptive PRDs with codebase exploration</summary>

<br>

**Adaptive Modes:**
- **Quick Mode**: Simple features (5-7 questions, lightweight spec)
- **Full Mode**: Complex features (15-20 questions, comprehensive spec)

**Auto-detected based on feature description** - you can override if needed.

**Codebase Exploration:**
- Analyzes existing patterns and architecture
- Finds similar features for reference
- Discovers authentication/authorization approaches
- Identifies testing frameworks and conventions
- Ensures new PRD follows project patterns

**PRD Contents:**
- Problem statement and solution overview
- Functional and non-functional requirements
- Multiple implementation phases
- Substories with acceptance criteria
- API/interface specifications
- Data schema design
- Testing strategy
- Security and performance considerations

**Platform-aware** - automatically tailors PRD structure for Rails backend, iOS mobile, or Android mobile development.

**Natural activation:**
- "Create a PRD for user authentication"
- "Let's plan out the booking feature"
- "Write a spec for the payment system"
- <ë<÷ "Créer un PRD", "planifier une fonctionnalité"

</details>

---

<details>
<summary><strong>=( implement-code</strong> - Implement PRDs substory-by-substory with smart guidance</summary>

<br>

**Guided Workflow:**
1. =Ë Implement substory code
2.  Update PRD with completion status
3. =¡ Suggest next steps (review, test, commit, continue)
4. ø Wait for your decision

**Features:**
- Architecture analysis before coding
- Follows existing project patterns
- Platform-specific best practices
- Incremental implementation (one substory at a time)
- Real-time PRD status updates
- Clear suggestions, no auto-invocations
- You orchestrate review ’ test ’ commit ’ PR

**Natural activation:** "Implement the authentication PRD" " "Build the booking feature" " <ë<÷ "Implémenter le PRD"

</details>

---

<details>
<summary><strong> implement-tests</strong> - Write comprehensive test suites</summary>

<br>

**Features:**
- Auto-detects testing framework (RSpec, Minitest, XCTest, JUnit+MockK)
- Writes tests matching your project's style
- Maps tests to PRD acceptance criteria
- Covers happy paths, edge cases, and error scenarios
- Platform-specific test patterns

**Test Types:** Unit " Integration " E2E " Platform-specific UI tests

**Natural activation:** "Write tests for the auth feature" " "Add tests for booking service" " <ë<÷ "Écrire des tests"

</details>

---

<details>
<summary><strong>=Ê track-prd-progress</strong> - Track and update PRD implementation status</summary>

<br>

**Features:**
- Real-time progress dashboard
- Velocity calculations
- Blocker identification and management
- Status reports (daily/weekly)
- ETA predictions

**Progress Metrics:**
```
=Ê Progress Metrics:
 Completed: 3 (37.5%)
= In Progress: 1 (12.5%)
=« Blocked: 1 (12.5%)
ó Pending: 3 (37.5%)

=È Velocity: 1.5 substories/day
<¯ ETA: 2 days
```

**Natural activation:** "Show PRD progress" " "Update the PRD status" " <ë<÷ "Suivre la progression"

</details>

---

<details>
<summary><strong>=¾ commit</strong> - Generate well-formatted commit messages</summary>

<br>

**Workflow:**
1. =Ê Show change summary (files, lines)
2. =Ý Generate conventional commit message
3.  Wait for your approval
4. =¾ Create commit only after "yes"

**Platform-aware features:**
- Automatic change type detection (feat/fix/refactor/etc.)
- Scope detection from file paths
- Detailed commit body with context
- Links to PRD substories
- Suggests splitting unrelated changes

**Generated Format:**
```
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication for Google, GitHub, and Apple.

- Add OAuth2 provider configurations
- Create callback handler for authentication flow
- Store OAuth tokens securely with encryption

Related: PRD-2024-10-25-auth (substory 1.3)

> Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Natural activation:** "Commit these changes" " "Save my work" " <ë<÷ "Committer"

</details>

---

<details>
<summary><strong>=€ create-pr</strong> - Generate comprehensive GitHub pull requests</summary>

<br>

**Workflow:**
1. L Error if uncommitted changes exist (tells you to commit first)
2. =Ê Analyze branch diff vs origin/main
3. =Ý Generate PR title and description
4.  Wait for your approval
5. =€ Create PR only after "yes"

**Generated PR Includes:**
- Summary (2-3 sentences)
- Related PRD and completed substories
- Changes by category (Added/Modified/Removed)
- Test coverage metrics
- All tests passing confirmation

**Natural activation:** "Create a pull request" " "Make a PR" " <ë<÷ "Créer une PR"

</details>

---

<details>
<summary><strong>= code-review</strong> - Multi-dimensional code analysis with auto-depth detection</summary>

<br>

**Auto-Depth Detection:**
- **Quick** (<100 lines, d3 files): 2-3 min, critical issues only
- **Standard** (100-500 lines, 4-15 files): 10-15 min, comprehensive
- **Deep** (>500 lines, >15 files): 20-30 min, full architecture

**Review Dimensions:**
- **Code Quality**: Readability, maintainability, complexity
- **Architecture**: Design patterns, SOLID principles
- **Security**: Auth/authz, input validation, secrets
- **Performance**: N+1 queries, memory leaks, algorithms
- **Testing**: Coverage, quality, edge cases

**Platform-specific checks:**
- **Rails**: Strong parameters, N+1 queries, migrations, ActiveRecord
- **iOS Swift**: Retain cycles, optional handling, main thread UI, async/await
- **Android Kotlin**: Context leaks, Coroutines, ViewModel, Hilt DI

**Output:**
- Findings by severity (=4 Critical, =à Major, =á Minor)
- File:line references with code examples
- Fix suggestions (you apply them)
- Positive feedback
- Approval recommendation
- Suggested next steps

**Natural activation:** "Review my code" " "Check my changes" " <ë<÷ "Réviser le code"

</details>
