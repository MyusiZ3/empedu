# Empedu Project (Empowering Education for Development and Understanding)

Empedu is a Flutter-based mobile application aimed at managing educational tasks efficiently. Below is the overview of the project's folder structure and its contents.

## Project Structure

empedu/
├── android/             # Android platform-specific code and configurations
├── ios/                 # iOS platform-specific code and configurations
├── lib/                 # Main Flutter application source code
│   ├── database/        # Local Database for contact
│   ├── models/          # Data models used in the application
│   ├── screens/         # Main screen ( Home,Profile,contact etc.)
│   ├── services/        # Authenticated services
│   ├── pages/           # UI pages (screens) of the application
│   │   ├── categories/  # Related content UI components
│   │   ├── chat  /      # chat features
│   │   ├── login/       # Login-related UI components
│   │   ├── signup/      # Signup-related UI components
│   │   ├── home/        # dumy
│   │   ├── dashboard/   # Main application dashboard
│   │   └── calculator/  # Calculator feature screen
│   ├── services/        # Services such as API calls, authentication,CHAT AUTH etc.
│   ├── utils/           # Utility functions and helpers
│   ├── widgets/         # Reusable UI components and widgets
│   ├── main.dart        # Entry point of the application, route controllers
│   └── firebase_options.dart # Firebase options
├── test/                # Unit and widget tests
├── .gitignore           # Git ignore file to exclude unnecessary files from version control
├── pubspec.yaml         # Flutter package dependencies
└── README.md            # Project documentation



### Folder Details

- **`android/`** and **`ios/`**:
  - These folders contain platform-specific code and configurations for Android and iOS platforms respectively.
  - You can configure settings specific to each platform here, such as permissions, native code, and platform-dependent configurations.

- **`lib/`**:
  - **`models/`**: Contains the data models that represent various entities within the application (e.g., User, Item).
  - **`pages/`**: The folder houses the UI pages (screens) of the application.
    - **`login/`**: Components related to the login screen (e.g., form fields, buttons).
    - **`signup/`**: Components related to the sign-up screen.
    - **`home/`**: Main dashboard or homepage UI components.
  - **`services/`**: Contains services such as API calls, authentication, and any other application logic that is not UI-related.
  - **`utils/`**: Utility functions and helpers that are used across the application, like validation, formatting, etc.
  - **`widgets/`**: Contains reusable components, like custom buttons, text fields, or other UI elements that can be used across multiple screens.
  - **`main.dart`**: This is the entry point of the Flutter application. It sets up the main app widget and routing.

- **`test/`**: Unit and widget tests for the app. It ensures the logic and UI components work as expected.
  
- **`pubspec.yaml`**: This file manages the dependencies of the Flutter project, including packages, assets, and other configurations.

- **`.gitignore`**: A file that specifies which files or directories should not be tracked by Git (e.g., build artifacts, temporary files, etc.).

### Setup Instructions

To set up this project locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/MyusiZ3/empedu.git


# HOW ?
- Navigate into the project directory:
    cd empedu
- Install dependencies:
    flutter pub get
- Run the app on your preferred platform:
    flutter run



## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.



