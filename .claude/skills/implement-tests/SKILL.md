---
name: implement-tests
description: Write comprehensive tests for PRD substories. Activates when user says write tests, add tests, test this code, create tests, or test coverage. French: écrire des tests, ajouter des tests, tester ce code.
---

# Implement Tests

Write comprehensive test suites for implemented features following platform-specific testing patterns.

## When to Activate

This skill activates when user:
- Says "write tests", "add tests", "create tests"
- Says "test this code", "add test coverage"
- Mentions "write unit tests", "add integration tests"
- References testing a specific file or feature
- French: "écrire des tests", "ajouter des tests", "tester ce code", "ajouter la couverture"

## Testing Workflow

### Step 1: Understand What to Test

**Gather context:**
```bash
# If related to PRD, read it
# If testing specific files, read them
# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)
```

**Load platform testing reference:**
- Read `.claude/skills/shared/references/${platform}/conventions.md`
- Focus on testing section
- Detect testing framework in use

**Ask user (if unclear):**
- "What should I test?" [specific file/feature/entire PRD substory]
- "Test level?" [unit/integration/e2e/all]

### Step 2: Detect Testing Framework

**Rails:**
```bash
# Check Gemfile.lock
if grep -q "minitest" Gemfile.lock || [ -d "test/" ]; then
    framework="minitest"
elif grep -q "rspec-rails" Gemfile.lock; then
    framework="rspec"
fi
```

**iOS Swift:**
```bash
# Check for Quick/Nimble or XCTest
if grep -q "Quick" *.xcodeproj/project.pbxproj; then
    framework="quick-nimble"
else
    framework="xctest"
fi
```

**Android Kotlin:**
```bash
# Check build.gradle for JUnit, Mockito, MockK
framework="junit-mockk"  # Default for Kotlin
```

### Step 3: Analyze Code to Test

**For each file/feature:**
1. Read the implementation code
2. Identify:
   - Public methods/functions
   - Business logic paths
   - Edge cases (nil/null, empty, boundary conditions)
   - Error scenarios
   - Dependencies (what to mock)
3. Extract acceptance criteria from PRD (if available)

### Step 4: Write Unit Tests

**Test business logic and models:**

**Rails (RSpec):**
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe '#oauth_connected?' do
    context 'when OAuth credentials exist' do
      let(:user) { create(:user, oauth_provider: 'google', oauth_uid: '123') }

      it 'returns true' do
        expect(user.oauth_connected?).to be true
      end
    end

    context 'when OAuth credentials missing' do
      let(:user) { create(:user, oauth_provider: nil) }

      it 'returns false' do
        expect(user.oauth_connected?).to be false
      end
    end
  end

  describe 'edge cases' do
    it 'handles nil email gracefully' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end
end
```

**iOS Swift (XCTest):**
```swift
// Tests/UserViewModelTests.swift
import XCTest
@testable import YourApp

final class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = UserViewModel(authService: mockAuthService)
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testOAuthLogin_Success() async throws {
        // Given
        let expectedUser = User(id: "123", email: "test@example.com")
        mockAuthService.oauthResult = .success(expectedUser)

        // When
        await sut.loginWithGoogle()

        // Then
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertEqual(sut.currentUser?.id, "123")
    }

    func testOAuthLogin_Failure() async {
        // Given
        mockAuthService.oauthResult = .failure(AuthError.invalidCredentials)

        // When
        await sut.loginWithGoogle()

        // Then
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

**Android Kotlin (JUnit + MockK):**
```kotlin
// app/src/test/java/com/example/UserViewModelTest.kt
class UserViewModelTest {
    private lateinit var viewModel: UserViewModel
    private lateinit var mockAuthRepository: AuthRepository

    @Before
    fun setup() {
        mockAuthRepository = mockk()
        viewModel = UserViewModel(mockAuthRepository)
    }

    @Test
    fun `oauthLogin success updates UI state`() = runTest {
        // Given
        val user = User(id = "123", email = "test@example.com")
        coEvery { mockAuthRepository.oauthLogin(any()) } returns Result.Success(user)

        // When
        viewModel.loginWithGoogle()

        // Then
        assertEquals(UiState.Success(user), viewModel.uiState.value)
        verify { mockAuthRepository.oauthLogin("google") }
    }

    @Test
    fun `oauthLogin failure shows error`() = runTest {
        // Given
        coEvery { mockAuthRepository.oauthLogin(any()) } returns
            Result.Error("Invalid credentials")

        // When
        viewModel.loginWithGoogle()

        // Then
        assert(viewModel.uiState.value is UiState.Error)
    }
}
```

### Step 5: Write Integration Tests

**Test interactions between components:**

**Rails:**
```ruby
# spec/requests/api/v1/auth_spec.rb
RSpec.describe 'API::V1::Auth', type: :request do
  describe 'POST /api/v1/auth/oauth/callback' do
    let(:oauth_params) do
      {
        provider: 'google',
        code: 'valid_code',
        redirect_uri: 'app://callback'
      }
    end

    context 'with valid OAuth code' do
      before do
        allow(GoogleOAuthService).to receive(:exchange_code)
          .and_return(user_data)
      end

      it 'returns JWT token' do
        post '/api/v1/auth/oauth/callback', params: oauth_params

        expect(response).to have_http_status(:ok)
        expect(json_response['token']).to be_present
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'with invalid OAuth code' do
      it 'returns error' do
        post '/api/v1/auth/oauth/callback', params: { provider: 'google', code: 'invalid' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end
end
```

### Step 6: Write E2E/UI Tests

**Test critical user flows:**

**iOS (XCUITest):**
```swift
// UITests/AuthenticationUITests.swift
final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testGoogleOAuthFlow() {
        // Given
        let loginButton = app.buttons["Login with Google"]

        // When
        loginButton.tap()

        // Wait for OAuth webview
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        // Then - after OAuth success, should see home screen
        let homeTitle = app.staticTexts["Home"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 10))
    }
}
```

**Android (Espresso):**
```kotlin
@Test
fun googleOAuthFlow_successfulLogin() {
    // Given
    onView(withId(R.id.googleLoginButton)).check(matches(isDisplayed()))

    // When
    onView(withId(R.id.googleLoginButton)).perform(click())

    // Then - OAuth webview should appear
    onView(withId(R.id.oauthWebView))
        .check(matches(isDisplayed()))

    // After OAuth success - home screen should load
    Thread.sleep(3000) // Wait for OAuth callback
    onView(withId(R.id.homeScreen))
        .check(matches(isDisplayed()))
}
```

### Step 7: Verify Acceptance Criteria

**Map tests to PRD acceptance criteria:**

```markdown
## Substory 1.1: User OAuth Model

**Acceptance Criteria:**
- [x] User model has oauth_provider field → ✅ Tested in user_spec.rb:23
- [x] User model has oauth_uid field → ✅ Tested in user_spec.rb:24
- [x] Unique index on (oauth_provider, oauth_uid) → ✅ Tested in user_spec.rb:45
- [x] #oauth_connected? method works → ✅ Tested in user_spec.rb:67-89

**Test Coverage:** 95% (48/50 lines)
```

### Step 8: Run Tests

**Execute test suite:**
```bash
# Rails
bundle exec rspec spec/models/user_spec.rb

# iOS
xcodebuild test -scheme YourApp -destination 'platform=iOS Simulator,name=iPhone 14'

# Android
./gradlew testDebugUnitTest
```

**Report results:**
```
✅ Tests Passed: 23/23
📊 Coverage: 95%
⏱️  Duration: 2.3s

All acceptance criteria verified!
```

### Step 9: Update PRD with Test Info

Add test details to substory:
```markdown
- ✅ [1.1] User OAuth model - Completed
  - Tests: 23 tests, 95% coverage
  - Test Files:
    - `spec/models/user_spec.rb`
    - `spec/requests/api/v1/auth_spec.rb`
```

## Test Quality Standards

Tests should:
- ✅ Cover happy paths
- ✅ Cover error scenarios
- ✅ Test edge cases (nil, empty, boundary values)
- ✅ Test concurrent scenarios (if applicable)
- ✅ Use mocks/stubs for external dependencies
- ✅ Be isolated (no test interdependence)
- ✅ Have clear Given/When/Then structure
- ✅ Have descriptive names
- ✅ Run fast (< 1s per test ideally)

## Output Format

```
📝 Writing tests for: User OAuth model
🔍 Detected framework: RSpec
📋 Test plan:
  - Unit: User model validations (5 tests)
  - Unit: #oauth_connected? method (4 tests)
  - Integration: OAuth callback endpoint (8 tests)
  - E2E: Google OAuth flow (2 tests)

✍️  Writing unit tests... Done!
✍️  Writing integration tests... Done!
✍️  Writing E2E tests... Done!

🧪 Running tests...
✅ 23/23 tests passed
📊 Coverage: 95%

All acceptance criteria verified ✅
```

## Guidelines

- Always detect testing framework first
- Follow project's existing test patterns
- Cover all acceptance criteria
- Include edge cases and error scenarios
- Mock external dependencies
- Keep tests fast and isolated
- Use descriptive test names
- Verify tests actually pass
- Report coverage metrics
- Update PRD with test info
