# Flutter Login App

This Flutter application demonstrates a user authentication system using Firebase Authentication and Google Sign-In. Below, you will find all the necessary information to understand and run this project.

## Table of Contents

1. [Features](#features)
2. [Getting Started](#getting-started)
3. [Running the App](#running-the-app)
4. [Contact](#contact)


## Features

- **User Authentication**: Sign up and sign in using email and password or Google account.
- **Password Reset**: Users can reset their password if they forget it.
- **Responsive Design**: The app adapts to different screen sizes, making it user-friendly on both mobile and desktop.
- **Password Validation**: Ensure strong passwords by checking criteria such as length and character diversity.

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- An IDE such as Visual Studio Code or Android Studio
- Firebase project configured with your app

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/exp_login_app.git
   cd exp_login_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Follow the instructions to add your app and download the `firebase_options.dart` file.
   - Replace the existing `firebase_options.dart` in the `lib` folder with your downloaded file.

## Running the App

To run the app, use the following command:
```bash
flutter run -d chrome --web-port=5555
```

for older version deployed refer to https://gauharturg.github.io/flutter_login_app/


## Contact

For further inquiries, feel free to reach out:

- **Name**: Gaukhar Turgambekova
- **Email**: gauharturg@gmail.com



