# Watcheshub Admin Panel (Web)

A web-based admin panel built with Flutter to manage the backend operations of the Watcheshub e-commerce application. This dashboard runs in any modern browser and provides administrators with tools to oversee products, brands, orders, users, and reviews.

## Features

-   **Dashboard:** A central overview of key application metrics.
-   **Authentication:** Secure login for administrators.
-   **Product Management:** Add, view, and edit product details.
-   **Brand Management:** Add and view brands available in the store.
-   **Order Management:** View and track customer orders.
-   **User Management:** Browse registered users.
-   **Review Management:** View and manage product reviews.

## Tech Stack

-   **Framework:** [Flutter for Web](https://flutter.dev/web)
-   **Language:** [Dart](https://dart.dev/)
-   **Backend & Database:** [Supabase](https://supabase.io/)
-   **State Management:** [Provider](https://pub.dev/packages/provider)
-   **Key Libraries:**
    -   `supabase_flutter`: For integration with Supabase backend.
    -   `provider`: For state management.
    -   `image_picker`: For selecting images from the device gallery.

## Prerequisites

Before you begin, ensure you have the following installed on your development machine:

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (with web support enabled)
-   [Dart SDK](https://dart.dev/get-dart)
-   A code editor like [VS Code](https://code.visualstudio.com/).
-   A modern web browser like [Google Chrome](https://www.google.com/chrome/).

## Installation Steps

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/adminapp.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd adminapp
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

## Environment Variables

This project connects to a Supabase backend. For security and best practices, it's recommended to manage API keys using environment variables rather than hardcoding them.

**Note:** The Supabase keys are currently hardcoded in `lib/main.dart`. You should move them to a `.env` file.

1.  Create a `.env` file in the project's root directory.
2.  Add your Supabase credentials to the `.env` file as follows:

    ```env
    # .env.example
    SUPABASE_URL=https://your-project-url.supabase.co
    SUPABASE_ANON_KEY=your-supabase-anonymous-key
    ```
3.  Ensure you add the `.env` file to your `.gitignore` to prevent committing sensitive keys.
4.  You will need to add a dependency like `flutter_dotenv` and update `lib/main.dart` to load these variables.

## Usage / How to Run the Project

This project is intended to be run as a web application.

-   **To run the app in a web browser (Google Chrome is recommended):**
    ```sh
    flutter run -d chrome
    ```
This will start a local web server and open the application in a new browser window.

## Folder Structure

Here is a high-level overview of the project's folder structure:

```
E:/E-project/adminapp/
├── lib/                      # Main application source code
│   ├── main.dart             # Application entry point
│   ├── models/               # Data models for brands, products, etc.
│   ├── providers/            # State management logic with Provider
│   ├── screens/              # UI screens and layouts
│   ├── utils/                # Utility files like AppRoutes and AppColors
│   └── widget/               # Reusable custom widgets
├── web/                      # Web-specific files (index.html, etc.)
├── assets/                   # Static assets like images and logos
├── test/                     # Application tests
├── pubspec.yaml              # Project metadata and dependencies
└── README.md                 # This file
```
*(Note: The `android` and `ios` folders are part of the standard Flutter project structure but are not used for this web-only application.)*

## API Endpoints

Not Applicable. This is a client-side Flutter application. It interacts with the Supabase backend via the `supabase_flutter` client library, not through traditional REST API endpoints defined within this project.

## Scripts / Commands

All scripts are standard `flutter` commands focused on web development.

-   **Install dependencies:**
    ```sh
    flutter pub get
    ```
-   **Run the application for web:**
    ```sh
    flutter run -d chrome
    ```
-   **Run tests:**
    ```sh
    flutter test
    ```
-   **Build the web application for production:**
    ```sh
    flutter build web
    ```
-   **Analyze code for errors and warnings:**
    ```sh
    flutter analyze
    ```

## Screenshots / Demo

*(This section is a placeholder. You can add screenshots of the application running in a web browser, showing the login page, dashboard, etc.)*

## Common Issues & Troubleshooting

-   **Build fails after pulling changes:** Run `flutter clean` to remove old build artifacts, then `flutter pub get` to ensure all dependencies are up-to-date before trying to build again.
-   **Supabase connection error:** Double-check that your Supabase URL and anon key are correct and that your Supabase project is active. Ensure your device has an active internet connection.
-   **Browser compatibility issues:** Test primarily on modern browsers like Chrome, Firefox, and Safari. Some features may not work as expected on older browsers.

## Future Improvements

-   Implement more detailed analytics and visual charts on the dashboard.
-   Add role-based access control (RBAC) for different types of administrators.
-   Integrate a real-time chat module for customer support.
-   Enhance filtering, sorting, and search capabilities across all management screens.

## Contribution Guidelines

We welcome contributions to improve this admin panel. Please follow these steps to contribute:

1.  **Fork** the repository on GitHub.
2.  Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name`.
3.  Make your changes and commit them with a clear, descriptive message.
4.  Push your changes to your forked repository: `git push origin feature/your-feature-name`.
5.  Open a **Pull Request** to the `main` branch of the original repository.

## License

Not specified. This project does not have a license file. Please add one if you intend to distribute or open-source this project.