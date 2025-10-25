# iOS Swift Conventions & Best Practices

## Project Structure

```
ProjectName/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Models/
│   ├── Reservation.swift
│   ├── ParkingSpot.swift
│   └── User.swift
├── ViewModels/
│   ├── ReservationListViewModel.swift
│   └── ReservationDetailViewModel.swift
├── Views/
│   ├── Screens/
│   │   ├── ReservationListView.swift
│   │   └── ReservationDetailView.swift
│   └── Components/
│       ├── ParkingSpotCard.swift
│       └── ReservationCell.swift
├── Services/
│   ├── APIService.swift
│   ├── ReservationService.swift
│   └── AuthService.swift
├── Networking/
│   ├── APIClient.swift
│   ├── Endpoint.swift
│   └── NetworkError.swift
├── Utilities/
│   ├── Extensions/
│   ├── Constants.swift
│   └── Helpers.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

## Naming Conventions

### Files & Types
- **PascalCase**: `ReservationListViewModel`, `ParkingSpotService`
- **Descriptive names**: `ReservationCreationRequest`, not `Request`
- **Suffixes**: `ViewController`, `View`, `ViewModel`, `Service`, `Manager`

### Variables & Functions
- **camelCase**: `parkingSpot`, `fetchReservations()`
- **Clear intent**: `isReservationActive`, not `check()`
- **Booleans**: Prefix with `is`, `has`, `should`, `can`

### Constants
- **Static properties**: `static let maxReservationDays = 30`
- **Enums for groups**: `struct Constants { enum API { ... } }`

## Architecture: MVVM

### Models

```swift
import Foundation

struct Reservation: Codable, Identifiable {
    let id: Int
    let userId: Int
    let parkingSpotId: Int
    let startsAt: Date
    let endsAt: Date
    let confirmationCode: String
    let status: ReservationStatus
    let totalPrice: Decimal
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case parkingSpotId = "parking_spot_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case confirmationCode = "confirmation_code"
        case status
        case totalPrice = "total_price"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var durationInHours: Double {
        endsAt.timeIntervalSince(startsAt) / 3600
    }

    var isActive: Bool {
        let now = Date()
        return startsAt <= now && endsAt > now
    }

    var isUpcoming: Bool {
        startsAt > Date()
    }
}

enum ReservationStatus: String, Codable {
    case pending
    case confirmed
    case active
    case completed
    case cancelled
}

struct ParkingSpot: Codable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let pricePerHour: Decimal
    let latitude: Double
    let longitude: Double
    let available: Bool
}
```

### ViewModels

```swift
import Foundation
import Combine

@MainActor
class ReservationListViewModel: ObservableObject {
    @Published var reservations: [Reservation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let reservationService: ReservationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(reservationService: ReservationServiceProtocol = ReservationService.shared) {
        self.reservationService = reservationService
    }

    func fetchReservations() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                reservations = try await reservationService.fetchReservations()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func cancelReservation(_ reservation: Reservation) async throws {
        try await reservationService.cancelReservation(id: reservation.id)
        await fetchReservations()
    }

    var upcomingReservations: [Reservation] {
        reservations.filter { $0.isUpcoming }
                   .sorted { $0.startsAt < $1.startsAt }
    }

    var activeReservations: [Reservation] {
        reservations.filter { $0.isActive }
    }
}
```

### SwiftUI Views

```swift
import SwiftUI

struct ReservationListView: View {
    @StateObject private var viewModel = ReservationListViewModel()
    @State private var showingAddReservation = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading reservations...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        viewModel.fetchReservations()
                    }
                } else if viewModel.reservations.isEmpty {
                    EmptyStateView(
                        title: "No Reservations",
                        message: "You don't have any reservations yet.",
                        actionTitle: "Make a Reservation"
                    ) {
                        showingAddReservation = true
                    }
                } else {
                    reservationsList
                }
            }
            .navigationTitle("My Reservations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReservation = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReservation) {
                AddReservationView()
            }
        }
        .task {
            viewModel.fetchReservations()
        }
    }

    private var reservationsList: some View {
        List {
            if !viewModel.upcomingReservations.isEmpty {
                Section("Upcoming") {
                    ForEach(viewModel.upcomingReservations) { reservation in
                        ReservationRow(reservation: reservation)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        try? await viewModel.cancelReservation(reservation)
                                    }
                                } label: {
                                    Label("Cancel", systemImage: "xmark")
                                }
                            }
                    }
                }
            }

            if !viewModel.activeReservations.isEmpty {
                Section("Active") {
                    ForEach(viewModel.activeReservations) { reservation in
                        ReservationRow(reservation: reservation)
                    }
                }
            }
        }
        .refreshable {
            viewModel.fetchReservations()
        }
    }
}

struct ReservationRow: View {
    let reservation: Reservation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reservation.confirmationCode)
                    .font(.headline)
                Spacer()
                StatusBadge(status: reservation.status)
            }

            Text(reservation.startsAt, style: .date)
                .font(.subheadline)
            Text("\(reservation.startsAt, style: .time) - \(reservation.endsAt, style: .time)")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Text("$\(reservation.totalPrice, format: .currency(code: "USD"))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(reservation.durationInHours, format: .number) hours")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Services

```swift
import Foundation

protocol ReservationServiceProtocol {
    func fetchReservations() async throws -> [Reservation]
    func createReservation(_ request: CreateReservationRequest) async throws -> Reservation
    func cancelReservation(id: Int) async throws
}

class ReservationService: ReservationServiceProtocol {
    static let shared = ReservationService()

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchReservations() async throws -> [Reservation] {
        try await apiClient.request(
            endpoint: .reservations,
            method: .get
        )
    }

    func createReservation(_ request: CreateReservationRequest) async throws -> Reservation {
        try await apiClient.request(
            endpoint: .createReservation,
            method: .post,
            body: request
        )
    }

    func cancelReservation(id: Int) async throws {
        try await apiClient.request(
            endpoint: .cancelReservation(id),
            method: .delete
        )
    }
}

struct CreateReservationRequest: Codable {
    let parkingSpotId: Int
    let startsAt: Date
    let endsAt: Date
    let vehicleType: String?

    enum CodingKeys: String, CodingKey {
        case parkingSpotId = "parking_spot_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case vehicleType = "vehicle_type"
    }
}
```

### API Client

```swift
import Foundation

class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://api.example.com")!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication token
        if let token = AuthService.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}

enum Endpoint {
    case reservations
    case createReservation
    case cancelReservation(Int)
    case parkingSpots

    var path: String {
        switch self {
        case .reservations:
            return "/api/v1/reservations"
        case .createReservation:
            return "/api/v1/reservations"
        case .cancelReservation(let id):
            return "/api/v1/reservations/\(id)"
        case .parkingSpots:
            return "/api/v1/parking_spots"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Server error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
```

## Memory Management

### Retain Cycles Prevention

```swift
// ❌ Bad - Retain cycle
class ViewController: UIViewController {
    var closure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        closure = {
            self.view.backgroundColor = .red  // Captures self strongly
        }
    }
}

// ✅ Good - Weak self
class ViewController: UIViewController {
    var closure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        closure = { [weak self] in
            self?.view.backgroundColor = .red
        }
    }
}

// ✅ Good - Unowned self (when self guaranteed to outlive closure)
Task { [unowned self] in
    await self.loadData()
}
```

### Combine Memory Management

```swift
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func setupBindings() {
        publisher
            .sink { [weak self] value in
                self?.handleValue(value)
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}
```

## Error Handling

```swift
enum ReservationError: LocalizedError {
    case spotUnavailable
    case invalidTimeRange
    case paymentFailed(String)

    var errorDescription: String? {
        switch self {
        case .spotUnavailable:
            return "This parking spot is not available for the selected time."
        case .invalidTimeRange:
            return "End time must be after start time."
        case .paymentFailed(let reason):
            return "Payment failed: \(reason)"
        }
    }
}

// Usage
func createReservation() async {
    do {
        let reservation = try await service.createReservation(request)
        // Handle success
    } catch let error as ReservationError {
        // Handle specific error
        showError(error.localizedDescription)
    } catch {
        // Handle generic error
        showError("An unexpected error occurred")
    }
}
```

## Testing

### Unit Tests

```swift
import XCTest
@testable import ParkingApp

final class ReservationViewModelTests: XCTestCase {
    var viewModel: ReservationListViewModel!
    var mockService: MockReservationService!

    override func setUp() {
        super.setUp()
        mockService = MockReservationService()
        viewModel = ReservationListViewModel(reservationService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchReservationsSuccess() async {
        // Given
        let expectedReservations = [
            Reservation.mock(id: 1),
            Reservation.mock(id: 2)
        ]
        mockService.reservationsToReturn = expectedReservations

        // When
        await viewModel.fetchReservations()

        // Then
        XCTAssertEqual(viewModel.reservations.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchReservationsFailure() async {
        // Given
        mockService.shouldFail = true

        // When
        await viewModel.fetchReservations()

        // Then
        XCTAssertTrue(viewModel.reservations.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}

// Mock Service
class MockReservationService: ReservationServiceProtocol {
    var reservationsToReturn: [Reservation] = []
    var shouldFail = false

    func fetchReservations() async throws -> [Reservation] {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return reservationsToReturn
    }

    func createReservation(_ request: CreateReservationRequest) async throws -> Reservation {
        if shouldFail {
            throw ReservationError.spotUnavailable
        }
        return Reservation.mock()
    }

    func cancelReservation(id: Int) async throws {
        if shouldFail {
            throw NetworkError.httpError(statusCode: 404)
        }
    }
}

// Test Helpers
extension Reservation {
    static func mock(
        id: Int = 1,
        userId: Int = 1,
        parkingSpotId: Int = 1
    ) -> Reservation {
        Reservation(
            id: id,
            userId: userId,
            parkingSpotId: parkingSpotId,
            startsAt: Date(),
            endsAt: Date().addingTimeInterval(3600),
            confirmationCode: "TEST123",
            status: .confirmed,
            totalPrice: 15.00,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
```

## Common Pitfalls & Best Practices

### ✅ DO

1. **Use async/await** - Modern concurrency
2. **Weak self in closures** - Prevent retain cycles
3. **SwiftUI previews** - Fast iteration
4. **Protocol-oriented** - Testability and flexibility
5. **Guard statements** - Early returns for clean code
6. **Optionals properly** - Use `if let`, `guard let`, not force unwrap
7. **Error handling** - Always handle errors gracefully
8. **Main thread for UI** - Use `@MainActor`
9. **Dependency injection** - For testability
10. **Constants/enums** - No magic strings or numbers

### ❌ DON'T

1. **Force unwrap (!!)** - Except for IBOutlets
2. **Implicitly unwrapped optionals** - Prefer explicit optionals
3. **Retain cycles** - Always use [weak self] in closures
4. **Block main thread** - Use async for network/heavy tasks
5. **Massive view controllers** - Extract to ViewModels
6. **Hardcoded strings** - Use localization
7. **Magic numbers** - Use named constants
8. **Ignore warnings** - Fix all warnings
9. **Skip tests** - Always test ViewModels and Services
10. **Nested callbacks** - Use async/await instead

## Code Style

### SwiftLint Rules

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - empty_string
line_length: 120
identifier_name:
  min_length: 3
  max_length: 40
```

### Formatting

```swift
// Spacing
func method() {  // Space after paren
    let x = 1  // Spaces around operators
}

// Multiline parameters
func longMethod(
    parameter1: String,
    parameter2: Int,
    parameter3: Bool
) -> String {
    // Implementation
}

// Guard statements
guard let value = optionalValue else {
    return
}

// If statements
if condition {
    // Do something
} else {
    // Do something else
}
```

## Performance

### Lazy Properties

```swift
class ViewModel {
    lazy var expensiveProperty: ExpensiveType = {
        // Only computed when first accessed
        return ExpensiveType()
    }()
}
```

### Image Caching

```swift
// Use SDWebImage or Kingfisher for remote images
import SDWebImage

imageView.sd_setImage(with: URL(string: imageURL))
```

### List Performance

```swift
// Use LazyVStack for long lists
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```
