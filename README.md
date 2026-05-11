# KTGK_flutter

This repository contains two separate Flutter projects: **Task1** and **Task2**.

## Task1: Shopping Demo
A simple shopping demo that includes a welcome screen, a product catalog, and a cart view managed with Provider.

### How to run
1. Install Flutter and ensure it is in your PATH.
2. From the repository root, run:
   ```bash
   cd Task1
   flutter pub get
   flutter run
   ```

### App flow
- **Welcome** → **Catalog** → **Cart**
- Add items from the catalog; view totals in the cart.

## Task2: Messenger App
A Firebase-backed messenger app with authentication flow, settings, and a home screen.

### How to run
1. Install Flutter and ensure it is in your PATH.
2. Configure Firebase for this Flutter app and ensure `firebase_options.dart` is generated.
3. Create a `.env` file in `Task2/` with the environment variables required by your Firebase setup (as referenced by the app).
4. From the repository root, run:
   ```bash
   cd Task2
   flutter pub get
   flutter run
   ```

### App flow
- **Splash** → **Login/Signup** → **Home** → **Settings**
- The app checks authentication state before routing to the home screen.


