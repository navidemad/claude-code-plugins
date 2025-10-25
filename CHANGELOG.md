# Changelog

All notable changes to Yespark Claude Plugins will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-27

### 🎉 Initial Release

**7 AI-powered skills for Rails, iOS Swift, and Android Kotlin development**

#### Added

- 📋 **generate-prd** - Create adaptive PRDs with codebase exploration
  - Quick mode (5-7 questions) and Full mode (15-20 questions)
  - Auto-detects complexity based on feature description
  - Explores existing codebase patterns

- 💻 **implement-code** - Write code substory-by-substory from PRDs
  - Guided workflow with suggestions (no auto-invocations)
  - Platform-specific best practices
  - Real-time PRD status updates

- 🧪 **implement-tests** - Write comprehensive test suites
  - Auto-detects testing framework
  - Maps tests to PRD acceptance criteria
  - Platform-specific test patterns

- 📊 **track-prd-progress** - Track and update PRD implementation status
  - Real-time progress dashboard
  - Velocity calculations and ETA predictions
  - Blocker identification

- 💾 **commit** - Generate well-formatted commit messages
  - Conventional commits format
  - Waits for approval before committing
  - Links to PRD substories

- 🚀 **create-pr** - Generate comprehensive PR descriptions
  - Analyzes branch diff vs origin/main
  - Requires clean branch (no uncommitted changes)
  - Waits for approval before creating

- 🔍 **code-review** - Multi-dimensional code quality analysis
  - Auto-depth detection (Quick/Standard/Deep)
  - Platform-specific checks
  - Reviews branch diff by default

#### Platform Support

- 💎 **Ruby on Rails** - Models, controllers, services, migrations, RSpec/Minitest
- 🍎 **iOS Swift** - MVVM, SwiftUI/UIKit, Combine, async/await
- 🤖 **Android Kotlin** - Clean Architecture, MVVM, Coroutines, Hilt DI

#### Philosophy

- 🎮 **Developer Control** - Tools, not automation
- 💡 **Suggestions** - Skills suggest next steps, you decide
- ✅ **Approval Gates** - Every action requires explicit confirmation
- 🗣️ **Natural Language** - Model-invoked, no slash commands
- 🌍 **Bilingual** - English and French support
