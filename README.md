# PlayerConnect

PlayerConnect is a sports field booking mobile application built with Flutter. This project emphasizes a clean, scalable, and maintainable codebase by implementing a Clean Architecture approach.

## Project Structure

This project follows the principles of **Clean Architecture**, separating the codebase into three distinct layers: `Presentation`, `Domain`, and `Data`. This separation of concerns makes the app easier to test, maintain, and scale.

-   **`lib/`**: This is the heart of the application, containing all the Dart code.
    -   **`presentation/`**: The UI layer, responsible for everything the user sees and interacts with.
        -   `screens/`: Contains the individual pages/screens of the app.
        -   `widgets/`: Holds reusable UI components (custom buttons, text fields, etc.) used across multiple screens.
        -   `bloc/`: Manages the application's state using the BLoC (Business Logic Component) pattern. It acts as a bridge between the UI and the business logic.
    -   **`domain/`**: The core business logic layer. It is the most independent layer, with no dependencies on UI or data sources.
        -   `entities/`: Defines the core business objects (e.g., `User`, `Booking`). These are plain Dart objects.
        -   `repositories/`: Defines the abstract contracts (interfaces) for data operations (e.g., `AuthRepository`).
        -   `usecases/`: Contains the specific business rules and actions the app can perform (e.g., `LoginUseCase`).
    -   **`data/`**: This layer is responsible for retrieving data from various sources (remote API, local database, etc.).
        -   `datasources/`: Handles the raw data retrieval (e.g., making HTTP requests).
        -   `models/`: Defines the data structures that map directly to the data sources (e.g., JSON from an API). These models include serialization logic (`fromJson`/`toJson`).
        -   `repositories/`: Contains the concrete implementations of the repository contracts defined in the `domain` layer.
    -   **`core/`**: Holds shared code, utilities, and configurations used across the entire application (e.g., dependency injection, routing, theme, error handling).
-   **`android/`**, **`ios/`**, **`web/`**: These directories contain platform-specific project files for configuration and setup.
-   **`assets/`**: Stores static files bundled with the app, such as images, icons, and fonts.
-   **`test/`**: Contains all application tests (unit, widget, and integration tests).
-   **`pubspec.yaml`**: Defines the project's metadata and dependencies.

---

## Implementing a New Feature

To maintain consistency and leverage the architectural benefits, new features should be implemented by following these steps, moving from the core business logic outwards to the UI.

### Step 1: Define the Core Logic (`domain` layer)

Start by defining the business rules and contracts, independent of any UI or data source.

1.  **Create/Update Entity**: In `lib/domain/entities/`, define the pure business object for your feature (e.g., `Review.dart`).
2.  **Define Repository Contract**: In `lib/domain/repositories/`, add or update the abstract class that defines the required data operations (e.g., `Future<Either<Failure, void>> submitReview(Review review)` in `ReviewRepository`).
3.  **Create Use Case**: In `lib/domain/usecases/`, create a class that encapsulates the specific action for this feature. This use case will be called by the presentation layer.

### Step 2: Implement Data Handling (`data` layer)

Implement the repository contract and fetch data from its source.

1.  **Create/Update Model**: In `lib/data/models/`, create a data model that maps to your data source (e.g., API JSON). This model should include `fromJson`/`toJson` methods, often with the help of `json_serializable` and `freezed`.
2.  **Implement Data Source**: In `lib/data/datasources/`, create a class to fetch the raw data (e.g., make a `POST` request to a `/reviews` endpoint using `dio`).
3.  **Implement Repository**: In `lib/data/repositories/`, create the concrete implementation of the repository contract from the `domain` layer. This class will call the data source, handle potential errors (like network exceptions), and map the data model to a domain entity before returning it.

### Step 3: Build the UI & State (`presentation` layer)

Develop the user-facing part of the feature.

1.  **Create BLoC/Cubit**: In `lib/presentation/bloc/`, create a new BLoC or Cubit to manage the feature's state. It will depend on the use case(s) from the `domain` layer.
    -   Define the **Events** the UI can dispatch (e.g., `SubmitReviewButtonPressed`).
    -   Define the **States** the UI will react to (e.g., `initial`, `loading`, `success`, `error`).
    -   Implement the **BLoC** to handle events, call the use case, and emit new states.
2.  **Develop the UI**: In `lib/presentation/screens/` and `lib/presentation/widgets/`, build the new screen or widget.
    -   Use a `BlocProvider` to make the BLoC available to the widget tree.
    -   Use a `BlocBuilder` or `BlocListener` to react to state changes and update the UI (e.g., show a loading indicator, display a success message).
    -   Dispatch events to the BLoC in response to user interactions.

### Step 4: Wire Up Dependencies

Finally, register all the new classes for dependency injection.

1.  **Register Dependencies**: In your dependency injection setup (likely using `get_it` and `injectable`), add annotations to your new classes (`@injectable`, `@lazySingleton`, etc.) so they can be automatically registered.
2.  **Run Code Generation**: If you've added new injectable classes or serializable models, run the build runner to generate the necessary code:
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

---

## Project Dependencies

This project utilizes a variety of Flutter packages and Dart libraries to provide its functionality. Below is a list of key dependencies and their primary uses:

### Core Flutter & UI

-   **`flutter`**: The core Flutter SDK for building cross-platform mobile applications.
-   **`cupertino_icons`**: Provides the Cupertino (iOS-style) icons for Flutter applications.
-   **`google_fonts`**: Allows easy integration of Google Fonts into the application for custom typography.
-   **`flutter_svg`**: Enables rendering SVG (Scalable Vector Graphics) images.

### State Management

-   **`flutter_bloc`**: A popular package for state management using the BLoC (Business Logic Component) pattern, promoting separation of concerns and testability.
-   **`equatable`**: Simplifies value equality in Dart, often used with BLoC states and entities to avoid manual `==` and `hashCode` overrides.

### Networking & Data Handling

-   **`dio`**: A powerful HTTP client for Dart, used for making network requests to the backend API.
-   **`json_annotation`**: Used with `json_serializable` for automatic JSON serialization and deserialization of data models.
-   **`dartz`**: A functional programming library for Dart, providing `Either` for handling success/failure scenarios in a type-safe way.

### Authentication & Storage

-   **`flutter_secure_storage`**: Provides a secure way to store sensitive data (like authentication tokens) on the device's keychain/keystore.
-   **`google_sign_in`**: Facilitates Google Sign-In authentication within the application.

### Location & Maps

-   **`geolocator`**: Provides cross-platform APIs for location services (e.g., getting current location, checking permissions).
-   **`geocoding`**: Offers geocoding and reverse geocoding functionalities (converting addresses to coordinates and vice-versa).
-   **`google_maps_flutter`**: Integrates Google Maps into the Flutter application.

### UI Components & Utilities

-   **`sliding_up_panel`**: A customizable sliding panel widget, useful for displaying content that can be expanded or collapsed.
-   **`flutter_card_swiper`**: Provides a customizable card swiper widget, often used for carousels or interactive card stacks.

### Dependency Injection

-   **`get_it`**: A simple service locator for Dart and Flutter projects, used for managing dependencies.
-   **`injectable`**: A code generator for `get_it`, simplifying the setup and registration of dependencies.

### Development Dependencies (Code Generation & Testing)

-   **`flutter_test`**: Flutter's testing framework.
-   **`flutter_lints`**: A set of recommended lint rules for Flutter projects to enforce code style and best practices.
-   **`build_runner`**: A tool for generating files from Dart code (e.g., for `json_serializable`, `injectable`, `freezed`).
-   **`injectable_generator`**: The code generator for the `injectable` package.
-   **`json_serializable`**: A code generator that automatically generates `fromJson` and `toJson` methods for Dart classes.
-   **`freezed`**: A code generator for data-classes, unions, and pattern-matching, reducing boilerplate for immutable models and states.
-   **`integration_test`**: A package for writing integration tests for Flutter applications.