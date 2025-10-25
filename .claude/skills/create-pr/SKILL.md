---
name: create-pr
description: Create GitHub PRs with comprehensive descriptions. Activates when user says create PR, make pull request, submit for review, open PR, or ready for review.
allowed-tools: Bash(git:*), Bash(gh pr create:*), Bash(.claude/skills/shared/scripts/detect_platform.sh:*), Read, Glob
---

# Create Pull Request

Create comprehensive GitHub pull requests with platform-aware descriptions linking to PRDs and commits.

## When to Activate

This skill activates automatically when the user:
- Says "create a PR" or "create pull request"
- Mentions "submit for review" or "ready for review"
- Says "I'm ready to push" or "ready for PR"
- Asks to "open a pull request" or "make a PR"
- References creating PR in PRD context

## Process

### Step 1: Gather Information

Use git commands and platform detection to collect data:

```bash
# Detect platform first
bash .claude/skills/shared/scripts/detect_platform.sh

# Get current branch
git branch --show-current

# Get commits since divergence from main
git log main..HEAD --oneline

# Get full diff
git diff main...HEAD

# Check for related PRD
ls docs/prds/
```

Analyze:
- What was added (new features/files)
- What was modified (improvements/fixes)
- What was removed (deprecated code)
- Detected platform (Rails/Android Kotlin/iOS Swift)
- Test coverage changes
- Database migrations present (Rails)
- New dependencies added

### Step 2: Find Related PRD

Search for related PRD by:
- Looking in commit messages for PRD references
- Checking docs/prds/ for recent PRDs
- Asking user if PRD exists for this work
- Reading PRD to understand which substories are completed

### Step 3: Generate PR Title

Format: `[type](scope): brief description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

Examples:
- `feat(auth): add OAuth2 social login support`
- `fix(api): prevent null pointer in user serializer`
- `refactor(mobile): extract booking logic to view models`

### Step 4: Generate PR Description

Create comprehensive description:

```markdown
## Summary
[2-3 sentence overview of what this PR accomplishes]

## Related PRD
[Link to PRD document if exists: `docs/prds/YYYY-MM-DD-feature-name.md`]

**Completed Substories:**
- ✅ [Phase X.Y] Substory title
- ✅ [Phase X.Z] Substory title

## Changes

### Added
- New authentication endpoints
- OAuth provider configurations
- Social login UI components

### Modified
- User model to support OAuth
- API client to handle OAuth tokens
- Login screen with social buttons

### Removed
- Deprecated legacy authentication code
- Unused helper methods

## Implementation Details

**Tailor this section based on detected platform:**

### For Rails Projects
**Models:**
- List new/modified models with key changes
- Example: `User`: Added oauth_provider, oauth_uid fields

**Controllers:**
- List new/modified controllers and endpoints
- Example: `Api::V1::AuthController`: New OAuth endpoints

**Services:**
- List new service objects
- Example: `OAuthService`: Handles provider authentication

**Migrations:**
- List database migrations
- Example: `20241025_add_oauth_to_users.rb`

### For Android Kotlin Projects
**Presentation Layer:**
- `Activities/Fragments`: List new/modified UI components
- `ViewModels`: List ViewModels with key changes

**Domain Layer:**
- `UseCases`: List business logic use cases
- `Models`: Domain models

**Data Layer:**
- `Repositories`: Data access implementations
- `API Services`: Network endpoints
- `DAOs`: Database access objects

### For iOS Swift Projects
**ViewControllers/Views:**
- List UI components (UIKit or SwiftUI)
- Example: `LoginViewController`: Added social login buttons

**ViewModels:**
- List ViewModels with responsibilities
- Example: `LoginViewModel`: Handles authentication logic

**Services:**
- List service layer implementations
- Example: `AuthService`: New OAuth methods

**Models:**
- List data models

## Testing

- [x] Unit tests added/updated
- [x] Integration tests added/updated
- [x] Manual testing completed
- [x] All tests passing locally

**Test Coverage:** 87% → 92% (+5%)

### Test Scenarios Covered
1. ✅ Successful OAuth login (Google, Apple, GitHub)
2. ✅ OAuth callback handling
3. ✅ Token storage and retrieval
4. ✅ Account linking for existing users
5. ✅ Error handling for failed OAuth
6. ✅ Token refresh flow

### Manual Testing
- ✅ Tested on Android (Pixel 6, API 33)
- ✅ Tested on iOS (iPhone 14, iOS 17)
- ✅ Verified against staging API
- ✅ Tested all OAuth providers

## Database Changes

### Migrations
```ruby
# 20241025_add_oauth_to_users.rb
add_column :users, :oauth_provider, :string
add_column :users, :oauth_uid, :string
add_index :users, [:oauth_provider, :oauth_uid], unique: true

# 20241025_create_oauth_tokens.rb
create_table :oauth_tokens do |t|
  t.references :user, null: false
  t.string :provider, null: false
  t.text :access_token, null: false
  t.text :refresh_token
  t.datetime :expires_at
end
```

**Migration Rollback Tested:** ✅ Yes

## API Changes

### New Endpoints

#### `POST /api/v1/auth/oauth/callback`
Handles OAuth provider callbacks

**Request:**
```json
{
  "provider": "google",
  "code": "auth_code_from_provider",
  "redirect_uri": "app://callback"
}
```

**Response (200):**
```json
{
  "token": "jwt_token",
  "user": {
    "id": 123,
    "email": "user@example.com",
    "oauth_provider": "google"
  }
}
```

**Errors:**
- 400: Invalid provider or code
- 422: Account linking conflict

### Modified Endpoints
None

### Breaking Changes
None - fully backward compatible

## Security Considerations

✅ **Security Checklist:**
- [x] OAuth state parameter validated (CSRF protection)
- [x] OAuth tokens stored encrypted
- [x] Provider signatures verified
- [x] No client secrets exposed in mobile apps
- [x] Rate limiting on OAuth endpoints
- [x] Proper redirect URI validation

**Security Review:**
- OAuth implementation follows RFC 6749
- PKCE used for mobile apps
- Tokens encrypted at rest
- Secure token refresh implemented

## Performance Impact

- No significant performance impact
- OAuth calls are async
- Token caching implemented
- Database indexes added for OAuth lookups

**Load Testing:**
- Tested 100 concurrent OAuth logins
- Average response time: 250ms
- No memory leaks detected

## Screenshots/Demos

[If UI changes, add screenshots or video links]

### Android
- Login screen with social buttons
- OAuth web view flow

### iOS
- Login screen with social buttons
- OAuth web view flow

## Documentation

- [x] API documentation updated (Swagger)
- [x] README updated with OAuth setup
- [x] Mobile SDK documentation updated
- [x] Code comments added for complex logic

## Deployment Notes

### Prerequisites
- [ ] OAuth app credentials configured in environment
- [ ] Environment variables set:
  - `GOOGLE_OAUTH_CLIENT_ID`
  - `GOOGLE_OAUTH_CLIENT_SECRET`
  - `APPLE_OAUTH_CLIENT_ID`
  - `GITHUB_OAUTH_CLIENT_ID`

### Deployment Steps
1. Deploy backend first (includes migrations)
2. Run migrations: `rails db:migrate`
3. Verify OAuth providers in admin panel
4. Deploy mobile apps (no special steps)

### Rollback Plan
If issues occur:
1. Revert backend deployment
2. Run migration rollback: `rails db:rollback STEP=2`
3. Mobile apps remain compatible (graceful degradation)

### Post-Deployment Verification
- [ ] Test OAuth login for each provider
- [ ] Monitor error rates
- [ ] Check OAuth token creation rates
- [ ] Verify user account linking

## Dependencies

**External:**
- OAuth provider apps configured
- No new gems or packages

**Internal:**
- None - feature is self-contained

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| OAuth provider outage | Users can't login | Support fallback to email/password |
| Account linking conflicts | Duplicate accounts | Implemented conflict resolution UI |

## Checklist

- [x] Code follows project style guidelines
- [x] Tests pass locally and in CI
- [x] No console.log or debugging code
- [x] Comments added for complex logic
- [x] Security best practices followed
- [x] No sensitive data hardcoded
- [x] Database migrations are reversible
- [x] API documentation updated
- [x] Mobile apps tested on real devices

## Related Issues/PRs

- Closes #456 (Add social login support)
- Related to #423 (User authentication refactor)
- Implements PRD: `docs/prds/2024-10-15-social-auth.md`

## Questions for Reviewers

1. Should we add LinkedIn as another OAuth provider?
2. Token expiration set to 7 days - is that appropriate?

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Step 5: Create the PR

**Execute in SINGLE message with multiple tool calls:**

```bash
# Ensure branch is pushed (if not already)
git push -u origin $(git branch --show-current)

# Create PR with generated description
gh pr create \
  --title "[title]" \
  --body "$(cat <<'EOF'
[generated description]
EOF
)" \
  --base main
```

**Note:** If user hasn't committed changes yet, inform them they need to commit first (can activate the `commit` skill).

### Step 6: Update PRD and Confirm

After PR is created:
1. Show PR URL and number
2. If related to PRD, update it with PR reference:
   ```markdown
   ## Implementation Status
   - ✅ Phase 1 completed - PR #123
   ```
3. Confirm success

## Output

Provide:
- ✅ PR created successfully
- 🔗 PR URL: https://github.com/org/repo/pull/123
- 📊 Summary: X files changed, Y commits
- 👥 Reviewers assigned
- 🏷️  Labels added
- 📋 Next: Wait for CI checks and review

## Best Practices

### Title
- Clear and concise
- Follow conventional commits format
- Mention key feature/fix

### Description
- Comprehensive but scannable
- Use sections and checkboxes
- Link to related issues and PRDs
- Include testing evidence
- Document deployment needs

### Context
- Explain WHY changes were made
- Link to discussions or decisions
- Note any trade-offs made

### Testing
- Be specific about test coverage
- List manual testing performed
- Include screenshots for UI changes

## Tips

- Check for uncommitted changes before creating PR
- Verify tests are passing
- Include performance implications
- Document breaking changes prominently
- Make it easy for reviewers to understand context
- Link back to PRD for traceability
