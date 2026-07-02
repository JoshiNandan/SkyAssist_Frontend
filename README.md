# SkyAssist ✈️

SkyAssist is a Flutter-based flight recovery application designed to help passengers manage travel disruptions seamlessly. Whether it's a flight cancellation or a delay, SkyAssist provides an intuitive flow to rebook flights, request refunds, or contact support.

## 🚀 Features

- **Booking Lookup**: Quickly find your journey using PNR and Last Name.
- **Disruption Management**: View real-time status of disrupted flights.
- **Alternate Flight Rebooking**: Browse and select from available alternate flights.
- **Fare Adjustment**: Automated calculation of fare differences with airport slip generation for manual collection.
- **OTP Verification**: Secure transaction processing via multi-factor authentication.
- **Refund & Support**: Integrated flow for requesting refunds or reaching out to airline support.
- **Responsive UI**: Optimized for various screen sizes with robust overflow protection.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider) (Strictly Provider-only architecture)
- **API Communication**: HTTP with wrapped JSON response handling.
- **Styling**: Custom `AppColors` system for brand consistency.

## 🏗 Project Structure

- `lib/providers/`: Contains `RecoveryProvider` for centralized state management.
- `lib/services/`: `ApiService` for backend communication.
- `lib/screens/`: UI implementation for the recovery flow (Lookup, Journey Status, OTP, Success, etc.).
- `lib/models/`: Data models for Bookings and Flight Segments.
- `lib/constants/`: API endpoints, color palettes, and string constants.

## 🚦 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- An active backend API for flight data

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/JoshiNandan/SkyAssist_Frontend.git
    ```
2.  **Navigate to project directory**:
    ```bash
    cd flight_attendent
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```

## 📱 Screenshots

*(Add screenshots here after running the app)*

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
