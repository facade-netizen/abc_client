# ABC Client

ABC Client is a modern Flutter Web application designed to provide a responsive, fast, and user-friendly experience across desktop, tablet, and mobile browsers.

## Features

* Responsive web design
* Cross-platform Flutter architecture
* Clean and scalable project structure
* State management support
* API integration ready
* Authentication ready
* Dark and Light theme support
* Optimized for modern browsers

## Technology Stack

* Flutter
* Dart
* REST APIs
* Material Design 3
* Responsive UI Components

## Getting Started

### Prerequisites

Before running the project, ensure you have:

* Flutter SDK installed
* Dart SDK installed
* Chrome or another supported browser

Verify your installation:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone <repository-url>
cd abc_client
```

Install dependencies:

```bash
flutter pub get
```

### Run the Application

Run the project in Chrome:

```bash
flutter run -d chrome
```

Build for production:

```bash
flutter build web
```

The production build will be generated inside:

```text
build/web
```

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── services/
│   └── utils/
├── features/
│   ├── authentication/
│   ├── dashboard/
│   └── settings/
├── widgets/
├── routes/
├── themes/
└── main.dart
```

## Configuration

Environment-specific settings can be configured using:

```bash
--dart-define
```

Example:

```bash
flutter run -d chrome \
  --dart-define=API_URL=https://api.example.com
```

## Deployment

Build the web application:

```bash
flutter build web --release
```

Deploy the contents of `build/web` to:

* Firebase Hosting
* AWS S3 + CloudFront
* Azure Static Web Apps
* Netlify
* Vercel
* Nginx Server

## Browser Support

* Google Chrome
* Microsoft Edge
* Mozilla Firefox
* Safari

## License

This project is licensed under the MIT License.
