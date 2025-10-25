# Ruby on Rails Conventions & Best Practices

## Testing Framework Detection

**Before writing tests, detect which framework the project uses:**
- Check `Gemfile.lock` for `rspec` or `minitest` gems
- Check for `spec/` directory (RSpec) vs `test/` directory (Minitest)
- **Prioritize Minitest** if both exist (some projects have both)
- Follow the detected framework's patterns and syntax

## Project Structure

```
app/
├── models/           # Business logic and data models
├── controllers/      # HTTP request handlers
├── services/         # Complex business logic
├── jobs/            # Background jobs (Sidekiq/ActiveJob)
├── mailers/         # Email sending
├── views/           # View templates (if using server-side rendering)
├── serializers/     # JSON API serializers
└── policies/        # Authorization (Pundit)

config/
├── routes.rb        # API routes
├── database.yml     # Database configuration
└── initializers/    # App initialization

db/
├── migrate/         # Database migrations
├── schema.rb        # Current database schema
└── seeds.rb         # Seed data

spec/ or test/       # Tests (RSpec or Minitest)
```

## Naming Conventions

### Models
- **Singular, PascalCase**: `User`, `ParkingSpot`, `Reservation`
- **File naming**: `user.rb`, `parking_spot.rb`, `reservation.rb`
- **Table names**: Plural, snake_case (`users`, `parking_spots`, `reservations`)

### Controllers
- **Plural, PascalCase + Controller**: `UsersController`, `Api::V1::ReservationsController`
- **File naming**: `users_controller.rb`, `api/v1/reservations_controller.rb`

### Services
- **Descriptive name + Service**: `BookingCreationService`, `PaymentProcessingService`
- **File naming**: `booking_creation_service.rb`
- **Location**: `app/services/`

### Jobs
- **Descriptive name + Job**: `ReservationReminderJob`, `PaymentProcessingJob`
- **File naming**: `reservation_reminder_job.rb`

## Code Patterns

### Models

```ruby
class Reservation < ApplicationRecord
  # Associations first
  belongs_to :user
  belongs_to :parking_spot

  # Validations
  validates :starts_at, :ends_at, presence: true
  validates :user_id, :parking_spot_id, presence: true
  validate :ends_after_starts
  validate :no_overlapping_reservations

  # Scopes
  scope :active, -> { where('ends_at > ?', Time.current) }
  scope :for_user, ->(user) { where(user: user) }
  scope :upcoming, -> { where('starts_at > ?', Time.current).order(:starts_at) }

  # Callbacks (use sparingly)
  before_create :set_confirmation_code
  after_create :send_confirmation_email

  # Instance methods
  def duration_in_hours
    ((ends_at - starts_at) / 1.hour).round(2)
  end

  def active?
    starts_at <= Time.current && ends_at > Time.current
  end

  private

  def ends_after_starts
    return if ends_at.blank? || starts_at.blank?
    errors.add(:ends_at, 'must be after start time') if ends_at <= starts_at
  end

  def no_overlapping_reservations
    overlapping = Reservation
      .where(parking_spot: parking_spot)
      .where.not(id: id)
      .where('starts_at < ? AND ends_at > ?', ends_at, starts_at)

    errors.add(:base, 'Spot already reserved for this time') if overlapping.exists?
  end

  def set_confirmation_code
    self.confirmation_code = SecureRandom.alphanumeric(8).upcase
  end

  def send_confirmation_email
    ReservationMailer.confirmation(self).deliver_later
  end
end
```

### Controllers (Thin controllers)

```ruby
class Api::V1::ReservationsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:show, :update, :destroy]

  # GET /api/v1/reservations
  def index
    @reservations = current_user.reservations
                                .includes(:parking_spot)
                                .page(params[:page])
                                .per(25)

    render json: @reservations, each_serializer: ReservationSerializer
  end

  # POST /api/v1/reservations
  def create
    result = ReservationCreationService.call(
      user: current_user,
      params: reservation_params
    )

    if result.success?
      render json: result.reservation,
             serializer: ReservationSerializer,
             status: :created
    else
      render json: { errors: result.errors },
             status: :unprocessable_entity
    end
  end

  private

  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(
      :parking_spot_id,
      :starts_at,
      :ends_at,
      :vehicle_type
    )
  end
end
```

### Services (Business logic)

```ruby
class ReservationCreationService
  def self.call(**args)
    new(**args).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
    @errors = []
  end

  def call
    validate_params
    return failure if @errors.any?

    ActiveRecord::Base.transaction do
      create_reservation
      charge_payment if reservation.requires_payment?
      send_notifications
    end

    success
  rescue StandardError => e
    Rails.logger.error("Reservation creation failed: #{e.message}")
    @errors << e.message
    failure
  end

  private

  attr_reader :user, :params, :errors
  attr_accessor :reservation

  def validate_params
    @errors << 'Parking spot not available' unless spot_available?
    @errors << 'Invalid time range' unless valid_time_range?
  end

  def spot_available?
    # Check spot availability logic
  end

  def valid_time_range?
    starts_at = Time.parse(params[:starts_at])
    ends_at = Time.parse(params[:ends_at])
    starts_at < ends_at && starts_at > Time.current
  rescue ArgumentError
    false
  end

  def create_reservation
    @reservation = Reservation.create!(
      user: user,
      parking_spot_id: params[:parking_spot_id],
      starts_at: params[:starts_at],
      ends_at: params[:ends_at]
    )
  end

  def charge_payment
    PaymentService.charge(user: user, amount: reservation.total_price)
  end

  def send_notifications
    ReservationMailer.confirmation(reservation).deliver_later
    SlackNotifier.notify_new_reservation(reservation)
  end

  def success
    Result.new(success: true, reservation: reservation)
  end

  def failure
    Result.new(success: false, errors: errors)
  end

  Result = Struct.new(:success, :reservation, :errors, keyword_init: true) do
    def success?
      success
    end
  end
end
```

### Migrations

```ruby
class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :parking_spot, null: false, foreign_key: true, index: true

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :confirmation_code, null: false
      t.integer :status, default: 0, null: false
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps
    end

    add_index :reservations, :confirmation_code, unique: true
    add_index :reservations, [:parking_spot_id, :starts_at]
    add_index :reservations, [:user_id, :created_at]
  end
end
```

## Testing with RSpec

### Model Specs

```ruby
# spec/models/reservation_spec.rb
require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:parking_spot) }
  end

  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }

    it 'validates end time is after start time' do
      reservation = build(:reservation, starts_at: 2.hours.from_now, ends_at: 1.hour.from_now)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:ends_at]).to include('must be after start time')
    end
  end

  describe '#duration_in_hours' do
    it 'calculates duration correctly' do
      reservation = create(:reservation,
                          starts_at: Time.current,
                          ends_at: 3.hours.from_now)
      expect(reservation.duration_in_hours).to eq(3.0)
    end
  end
end
```

### Controller Specs

```ruby
# spec/controllers/api/v1/reservations_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'POST #create' do
    let(:spot) { create(:parking_spot) }
    let(:valid_params) do
      {
        reservation: {
          parking_spot_id: spot.id,
          starts_at: 1.hour.from_now,
          ends_at: 3.hours.from_now
        }
      }
    end

    context 'with valid params' do
      it 'creates a new reservation' do
        expect {
          post :create, params: valid_params
        }.to change(Reservation, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable_entity status' do
        invalid_params = valid_params.deep_merge(
          reservation: { ends_at: 30.minutes.from_now }
        )
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

## Common Pitfalls & Best Practices

### ✅ DO

1. **Use strong parameters** - Always whitelist params
2. **Keep controllers thin** - Business logic in services/models
3. **Use database constraints** - Don't rely only on validations
4. **Add database indexes** - For foreign keys and query columns
5. **Use transactions** - For multi-step operations
6. **Eager load associations** - Avoid N+1 queries with `includes`
7. **Use background jobs** - For emails, external APIs, heavy processing
8. **Write tests first** - TDD/BDD approach
9. **Use serializers** - For consistent JSON responses
10. **Follow RESTful conventions** - Standard CRUD operations

### ❌ DON'T

1. **Fat controllers** - Move logic to models/services
2. **Fat models** - Extract to concerns/services when too complex
3. **Callbacks for everything** - Makes testing and debugging hard
4. **Skip database indexes** - Causes performance issues
5. **Use `find_by_sql`** - Use ActiveRecord query interface
6. **Ignore N+1 queries** - Use `bullet` gem to detect
7. **Put logic in views** - Keep views simple
8. **Skip error handling** - Always handle exceptions
9. **Hardcode values** - Use constants or config
10. **Ignore security** - Use strong parameters, sanitize inputs

## Performance Optimization

### N+1 Query Prevention

```ruby
# Bad - N+1 query
@reservations = Reservation.all
@reservations.each do |r|
  puts r.user.name  # N queries
  puts r.parking_spot.name  # N queries
end

# Good - Eager loading
@reservations = Reservation.includes(:user, :parking_spot).all
@reservations.each do |r|
  puts r.user.name  # No additional query
  puts r.parking_spot.name  # No additional query
end
```

### Counter Caches

```ruby
# Add to migration
add_column :parking_spots, :reservations_count, :integer, default: 0

# Add to model
class Reservation < ApplicationRecord
  belongs_to :parking_spot, counter_cache: true
end

# Now you can use
parking_spot.reservations_count  # No COUNT query needed
```

### Database Indexes

```ruby
# Add indexes for:
# - Foreign keys
# - Columns used in WHERE clauses
# - Columns used in ORDER BY
# - Columns used in JOINs
# - Unique constraints

add_index :reservations, :user_id
add_index :reservations, :parking_spot_id
add_index :reservations, [:parking_spot_id, :starts_at]
add_index :reservations, :confirmation_code, unique: true
```

## Security

### Strong Parameters

```ruby
def reservation_params
  params.require(:reservation).permit(
    :parking_spot_id,
    :starts_at,
    :ends_at,
    :vehicle_type
  )
end
```

### Authorization (Pundit)

```ruby
class ReservationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user && record.starts_at > Time.current
  end
end
```

### SQL Injection Prevention

```ruby
# Bad - Vulnerable to SQL injection
User.where("email = '#{params[:email]}'")

# Good - Parameterized query
User.where(email: params[:email])

# Good - Placeholder
User.where("email = ?", params[:email])
```

## API Response Format

### Success Response

```json
{
  "id": 123,
  "user_id": 456,
  "parking_spot_id": 789,
  "starts_at": "2024-10-25T10:00:00Z",
  "ends_at": "2024-10-25T12:00:00Z",
  "confirmation_code": "ABC12345",
  "status": "confirmed",
  "total_price": "15.00",
  "created_at": "2024-10-24T15:30:00Z",
  "updated_at": "2024-10-24T15:30:00Z"
}
```

### Error Response

```json
{
  "errors": {
    "ends_at": ["must be after start time"],
    "parking_spot": ["is not available"]
  }
}
```

## Background Jobs

```ruby
class ReservationReminderJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    return unless reservation.starts_at > 1.hour.from_now

    ReservationMailer.reminder(reservation).deliver_now
  end
end

# Schedule job
ReservationReminderJob.perform_later(reservation.id)

# Schedule for specific time
ReservationReminderJob.set(wait_until: reservation.starts_at - 1.hour)
                      .perform_later(reservation.id)
```
