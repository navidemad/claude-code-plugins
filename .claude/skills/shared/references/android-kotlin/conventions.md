# Android Kotlin Conventions & Best Practices

## Project Structure (Clean Architecture + MVVM)

```
app/src/main/
├── java/com/yespark/app/
│   ├── di/                    # Dependency Injection (Hilt/Koin)
│   │   ├── AppModule.kt
│   │   └── NetworkModule.kt
│   ├── data/
│   │   ├── local/            # Room database
│   │   │   ├── dao/
│   │   │   ├── database/
│   │   │   └── entity/
│   │   ├── remote/           # Retrofit APIs
│   │   │   ├── api/
│   │   │   └── dto/
│   │   └── repository/       # Repository implementations
│   ├── domain/
│   │   ├── model/            # Domain models
│   │   ├── repository/       # Repository interfaces
│   │   └── usecase/          # Use cases/Interactors
│   ├── presentation/
│   │   ├── ui/
│   │   │   ├── reservations/
│   │   │   │   ├── ReservationListFragment.kt
│   │   │   │   ├── ReservationListViewModel.kt
│   │   │   │   └── ReservationAdapter.kt
│   │   │   └── spots/
│   │   └── MainActivity.kt
│   └── utils/
│       ├── extensions/
│       ├── Constants.kt
│       └── Result.kt
└── res/
    ├── layout/
    ├── values/
    └── drawable/
```

## Naming Conventions

### Files & Classes
- **PascalCase**: `ReservationListViewModel`, `ParkingSpotRepository`
- **Suffixes**: `Activity`, `Fragment`, `ViewModel`, `Adapter`, `Repository`, `UseCase`
- **Layout files**: `fragment_reservation_list.xml`, `item_parking_spot.xml`
- **Drawables**: `ic_parking_24dp.xml`, `bg_rounded_card.xml`

### Variables & Functions
- **camelCase**: `parkingSpot`, `fetchReservations()`
- **Boolean prefix**: `isLoading`, `hasReservation`, `canCancel`
- **Constants**: `UPPER_SNAKE_CASE` for object constants

## Architecture: MVVM + Clean Architecture

### Domain Models

```kotlin
package com.yespark.app.domain.model

import java.time.LocalDateTime
import java.math.BigDecimal

data class Reservation(
    val id: Int,
    val userId: Int,
    val parkingSpotId: Int,
    val startsAt: LocalDateTime,
    val endsAt: LocalDateTime,
    val confirmationCode: String,
    val status: ReservationStatus,
    val totalPrice: BigDecimal,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    val durationInHours: Double
        get() = java.time.Duration.between(startsAt, endsAt).toHours().toDouble()

    val isActive: Boolean
        get() {
            val now = LocalDateTime.now()
            return startsAt <= now && endsAt > now
        }

    val isUpcoming: Boolean
        get() = startsAt > LocalDateTime.now()
}

enum class ReservationStatus {
    PENDING,
    CONFIRMED,
    ACTIVE,
    COMPLETED,
    CANCELLED
}

data class ParkingSpot(
    val id: Int,
    val name: String,
    val address: String,
    val pricePerHour: BigDecimal,
    val latitude: Double,
    val longitude: Double,
    val available: Boolean
)
```

### Repository Pattern

```kotlin
// Domain layer - Interface
package com.yespark.app.domain.repository

import com.yespark.app.domain.model.Reservation
import com.yespark.app.utils.Result
import kotlinx.coroutines.flow.Flow

interface ReservationRepository {
    fun getReservations(): Flow<Result<List<Reservation>>>
    suspend fun createReservation(
        parkingSpotId: Int,
        startsAt: LocalDateTime,
        endsAt: LocalDateTime
    ): Result<Reservation>
    suspend fun cancelReservation(id: Int): Result<Unit>
}

// Data layer - Implementation
package com.yespark.app.data.repository

import com.yespark.app.data.remote.api.ReservationApi
import com.yespark.app.data.remote.dto.toReservation
import com.yespark.app.domain.model.Reservation
import com.yespark.app.domain.repository.ReservationRepository
import com.yespark.app.utils.Result
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

class ReservationRepositoryImpl @Inject constructor(
    private val api: ReservationApi
) : ReservationRepository {

    override fun getReservations(): Flow<Result<List<Reservation>>> = flow {
        emit(Result.Loading)
        try {
            val response = api.getReservations()
            emit(Result.Success(response.map { it.toReservation() }))
        } catch (e: Exception) {
            emit(Result.Error(e.message ?: "Unknown error occurred"))
        }
    }

    override suspend fun createReservation(
        parkingSpotId: Int,
        startsAt: LocalDateTime,
        endsAt: LocalDateTime
    ): Result<Reservation> {
        return try {
            val request = CreateReservationRequest(
                parkingSpotId = parkingSpotId,
                startsAt = startsAt,
                endsAt = endsAt
            )
            val response = api.createReservation(request)
            Result.Success(response.toReservation())
        } catch (e: Exception) {
            Result.Error(e.message ?: "Failed to create reservation")
        }
    }

    override suspend fun cancelReservation(id: Int): Result<Unit> {
        return try {
            api.cancelReservation(id)
            Result.Success(Unit)
        } catch (e: Exception) {
            Result.Error(e.message ?: "Failed to cancel reservation")
        }
    }
}
```

### ViewModel

```kotlin
package com.yespark.app.presentation.ui.reservations

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yespark.app.domain.model.Reservation
import com.yespark.app.domain.repository.ReservationRepository
import com.yespark.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ReservationListViewModel @Inject constructor(
    private val repository: ReservationRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<ReservationUiState>(ReservationUiState.Loading)
    val uiState: StateFlow<ReservationUiState> = _uiState.asStateFlow()

    private val _events = MutableSharedFlow<ReservationEvent>()
    val events: SharedFlow<ReservationEvent> = _events.asSharedFlow()

    init {
        loadReservations()
    }

    fun loadReservations() {
        viewModelScope.launch {
            repository.getReservations().collect { result ->
                _uiState.value = when (result) {
                    is Result.Loading -> ReservationUiState.Loading
                    is Result.Success -> {
                        if (result.data.isEmpty()) {
                            ReservationUiState.Empty
                        } else {
                            ReservationUiState.Success(
                                upcoming = result.data.filter { it.isUpcoming },
                                active = result.data.filter { it.isActive }
                            )
                        }
                    }
                    is Result.Error -> ReservationUiState.Error(result.message)
                }
            }
        }
    }

    fun cancelReservation(reservation: Reservation) {
        viewModelScope.launch {
            when (val result = repository.cancelReservation(reservation.id)) {
                is Result.Success -> {
                    _events.emit(ReservationEvent.ReservationCancelled)
                    loadReservations()
                }
                is Result.Error -> {
                    _events.emit(ReservationEvent.ShowError(result.message))
                }
                is Result.Loading -> {} // No-op
            }
        }
    }
}

sealed class ReservationUiState {
    object Loading : ReservationUiState()
    object Empty : ReservationUiState()
    data class Success(
        val upcoming: List<Reservation>,
        val active: List<Reservation>
    ) : ReservationUiState()
    data class Error(val message: String) : ReservationUiState()
}

sealed class ReservationEvent {
    object ReservationCancelled : ReservationEvent()
    data class ShowError(val message: String) : ReservationEvent()
}
```

### Fragment (View)

```kotlin
package com.yespark.app.presentation.ui.reservations

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.snackbar.Snackbar
import com.yespark.app.databinding.FragmentReservationListBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

@AndroidEntryPoint
class ReservationListFragment : Fragment() {

    private var _binding: FragmentReservationListBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ReservationListViewModel by viewModels()
    private val adapter = ReservationAdapter(
        onCancelClick = { reservation ->
            viewModel.cancelReservation(reservation)
        }
    )

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentReservationListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        observeUiState()
        observeEvents()

        binding.swipeRefresh.setOnRefreshListener {
            viewModel.loadReservations()
        }

        binding.fabAdd.setOnClickListener {
            // Navigate to add reservation screen
        }
    }

    private fun setupRecyclerView() {
        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = this@ReservationListFragment.adapter
        }
    }

    private fun observeUiState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    binding.swipeRefresh.isRefreshing = false

                    when (state) {
                        is ReservationUiState.Loading -> {
                            binding.progressBar.visibility = View.VISIBLE
                            binding.recyclerView.visibility = View.GONE
                            binding.emptyView.visibility = View.GONE
                        }
                        is ReservationUiState.Empty -> {
                            binding.progressBar.visibility = View.GONE
                            binding.recyclerView.visibility = View.GONE
                            binding.emptyView.visibility = View.VISIBLE
                        }
                        is ReservationUiState.Success -> {
                            binding.progressBar.visibility = View.GONE
                            binding.recyclerView.visibility = View.VISIBLE
                            binding.emptyView.visibility = View.GONE

                            val allReservations = state.active + state.upcoming
                            adapter.submitList(allReservations)
                        }
                        is ReservationUiState.Error -> {
                            binding.progressBar.visibility = View.GONE
                            Snackbar.make(binding.root, state.message, Snackbar.LENGTH_LONG).show()
                        }
                    }
                }
            }
        }
    }

    private fun observeEvents() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.events.collect { event ->
                    when (event) {
                        is ReservationEvent.ReservationCancelled -> {
                            Snackbar.make(
                                binding.root,
                                "Reservation cancelled successfully",
                                Snackbar.LENGTH_SHORT
                            ).show()
                        }
                        is ReservationEvent.ShowError -> {
                            Snackbar.make(
                                binding.root,
                                event.message,
                                Snackbar.LENGTH_LONG
                            ).show()
                        }
                    }
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

### RecyclerView Adapter

```kotlin
package com.yespark.app.presentation.ui.reservations

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yespark.app.databinding.ItemReservationBinding
import com.yespark.app.domain.model.Reservation
import java.time.format.DateTimeFormatter

class ReservationAdapter(
    private val onCancelClick: (Reservation) -> Unit
) : ListAdapter<Reservation, ReservationAdapter.ViewHolder>(DiffCallback()) {

    override on CreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemReservationBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ViewHolder(binding, onCancelClick)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class ViewHolder(
        private val binding: ItemReservationBinding,
        private val onCancelClick: (Reservation) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(reservation: Reservation) {
            binding.apply {
                tvConfirmationCode.text = reservation.confirmationCode
                tvDate.text = reservation.startsAt.format(DateTimeFormatter.ofPattern("MMM dd, yyyy"))
                tvTime.text = "${reservation.startsAt.format(timeFormatter)} - ${reservation.endsAt.format(timeFormatter)}"
                tvPrice.text = "$${reservation.totalPrice}"
                tvDuration.text = "${reservation.durationInHours} hours"

                chipStatus.text = reservation.status.name
                chipStatus.setBackgroundColorResource(
                    when (reservation.status) {
                        ReservationStatus.ACTIVE -> R.color.status_active
                        ReservationStatus.CONFIRMED -> R.color.status_confirmed
                        else -> R.color.status_default
                    }
                )

                btnCancel.apply {
                    isEnabled = reservation.isUpcoming
                    setOnClickListener { onCancelClick(reservation) }
                }
            }
        }

        companion object {
            private val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
        }
    }

    private class DiffCallback : DiffUtil.ItemCallback<Reservation>() {
        override fun areItemsTheSame(oldItem: Reservation, newItem: Reservation): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Reservation, newItem: Reservation): Boolean {
            return oldItem == newItem
        }
    }
}
```

### Networking (Retrofit)

```kotlin
package com.yespark.app.data.remote.api

import com.yespark.app.data.remote.dto.ReservationDto
import com.yespark.app.data.remote.dto.CreateReservationRequest
import retrofit2.http.*

interface ReservationApi {
    @GET("api/v1/reservations")
    suspend fun getReservations(): List<ReservationDto>

    @POST("api/v1/reservations")
    suspend fun createReservation(
        @Body request: CreateReservationRequest
    ): ReservationDto

    @DELETE("api/v1/reservations/{id}")
    suspend fun cancelReservation(@Path("id") id: Int)
}

// DTO (Data Transfer Object)
package com.yespark.app.data.remote.dto

import com.google.gson.annotations.SerializedName
import com.yespark.app.domain.model.Reservation
import java.time.LocalDateTime

data class ReservationDto(
    val id: Int,
    @SerializedName("user_id") val userId: Int,
    @SerializedName("parking_spot_id") val parkingSpotId: Int,
    @SerializedName("starts_at") val startsAt: String,
    @SerializedName("ends_at") val endsAt: String,
    @SerializedName("confirmation_code") val confirmationCode: String,
    val status: String,
    @SerializedName("total_price") val totalPrice: String,
    @SerializedName("created_at") val createdAt: String,
    @SerializedName("updated_at") val updatedAt: String
)

fun ReservationDto.toReservation(): Reservation {
    return Reservation(
        id = id,
        userId = userId,
        parkingSpotId = parkingSpotId,
        startsAt = LocalDateTime.parse(startsAt),
        endsAt = LocalDateTime.parse(endsAt),
        confirmationCode = confirmationCode,
        status = ReservationStatus.valueOf(status.uppercase()),
        totalPrice = BigDecimal(totalPrice),
        createdAt = LocalDateTime.parse(createdAt),
        updatedAt = LocalDateTime.parse(updatedAt)
    )
}
```

### Dependency Injection (Hilt)

```kotlin
package com.yespark.app.di

import com.yespark.app.data.remote.api.ReservationApi
import com.yespark.app.data.repository.ReservationRepositoryImpl
import com.yespark.app.domain.repository.ReservationRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .addInterceptor { chain ->
                val request = chain.request().newBuilder()
                    .addHeader("Authorization", "Bearer ${getToken()}")
                    .build()
                chain.proceed(request)
            }
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideReservationApi(retrofit: Retrofit): ReservationApi {
        return retrofit.create(ReservationApi::class.java)
    }
}

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideReservationRepository(
        api: ReservationApi
    ): ReservationRepository {
        return ReservationRepositoryImpl(api)
    }
}
```

## Testing

### Unit Tests (ViewModel)

```kotlin
package com.yespark.app.presentation.ui.reservations

import app.cash.turbine.test
import com.yespark.app.domain.model.Reservation
import com.yespark.app.domain.repository.ReservationRepository
import com.yespark.app.utils.Result
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class ReservationListViewModelTest {

    private lateinit var viewModel: ReservationListViewModel
    private lateinit var repository: ReservationRepository
    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        repository = mockk()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `when loadReservations succeeds, state is Success`() = runTest {
        // Given
        val reservations = listOf(
            Reservation.mock(id = 1),
            Reservation.mock(id = 2)
        )
        coEvery { repository.getReservations() } returns flowOf(Result.Success(reservations))

        // When
        viewModel = ReservationListViewModel(repository)

        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertTrue(state is ReservationUiState.Success)
            assertEquals(2, (state as ReservationUiState.Success).upcoming.size)
        }
    }

    @Test
    fun `when loadReservations fails, state is Error`() = runTest {
        // Given
        val errorMessage = "Network error"
        coEvery { repository.getReservations() } returns flowOf(Result.Error(errorMessage))

        // When
        viewModel = ReservationListViewModel(repository)

        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertTrue(state is ReservationUiState.Error)
            assertEquals(errorMessage, (state as ReservationUiState.Error).message)
        }
    }
}
```

## Common Pitfalls & Best Practices

### ✅ DO

1. **Use Kotlin Coroutines** - For asynchronous operations
2. **ViewBinding** - Type-safe view access
3. **Hilt/Koin** - Dependency injection
4. **StateFlow/SharedFlow** - State management
5. **Sealed classes** - UI states and events
6. **Repository pattern** - Data abstraction
7. **Clean Architecture** - Separation of concerns
8. **DiffUtil** - Efficient RecyclerView updates
9. **Resource qualifiers** - For different screen sizes
10. **Proguard rules** - For release builds

### ❌ DON'T

1. **Context leaks** - Use ApplicationContext when appropriate
2. **Block main thread** - Use coroutines/background threads
3. **Memory leaks** - Clean up listeners, cancel jobs
4. **Hardcoded strings** - Use string resources
5. **findViewById** - Use ViewBinding instead
6. **AsyncTask** - Use Coroutines instead (deprecated)
7. **Ignore lifecycle** - Use lifecycle-aware components
8. **Large Activities** - Extract to Fragments/ViewModels
9. **Nest callbacks** - Use Coroutines
10. **Skip null safety** - Use Kotlin's null safety features

## Performance

### LazyColumn (Jetpack Compose)

```kotlin
@Composable
fun ReservationList(reservations: List<Reservation>) {
    LazyColumn {
        items(reservations) { reservation ->
            ReservationCard(reservation)
        }
    }
}
```

### Image Loading (Coil)

```kotlin
dependencies {
    implementation("io.coil-kt:coil-compose:2.4.0")
}

@Composable
fun ParkingSpotImage(url: String) {
    AsyncImage(
        model = url,
        contentDescription = null,
        modifier = Modifier.fillMaxWidth()
    )
}
```

## Build Configuration

```kotlin
// app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("kotlin-kapt")
    id("dagger.hilt.android.plugin")
}

android {
    namespace = "com.yespark.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yespark.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        viewBinding = true
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.3"
    }
}

dependencies {
    // Hilt
    implementation("com.google.dagger:hilt-android:2.48")
    kapt("com.google.dagger:hilt-compiler:2.48")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")

    // Room
    implementation("androidx.room:room-runtime:2.6.0")
    implementation("androidx.room:room-ktx:2.6.0")
    kapt("androidx.room:room-compiler:2.6.0")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("app.cash.turbine:turbine:1.0.0")
}
```
