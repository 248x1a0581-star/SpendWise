# SpendWise

SpendWise is a Flutter-based personal expense tracker. Users register, log in,
and record daily expenses by category. Everything is stored locally on the
device, so the app works offline.

## Features

- Splash screen with automatic session check
- Register and Login with form validation (passwords stored as SHA-256 hashes)
- Persistent login session and Logout
- Add, Edit, Delete expense (with delete confirmation)
- Expense detail screen
- Search by title or note
- Category-wise filtering (Food, Travel, Shopping, Bills, Education, Health, Entertainment, Other)
- Monthly spending summary card
- Profile screen with user info and expense count
- Empty-state and error handling
- Material 3 user interface

## Technologies Used

- Flutter and Dart
- Provider (state management)
- shared_preferences (local storage)
- intl (date and currency formatting)
- crypto (password hashing)

## Project Structure

```
lib/
  main.dart
  models/        app_user.dart, expense.dart
  providers/     auth_provider.dart, expense_provider.dart
  theme/         app_theme.dart
  screens/
    splash/      splash_screen.dart
    auth/        login_screen.dart, register_screen.dart
    home/        home_screen.dart
    add_expense/ add_edit_expense_screen.dart
    detail/      expense_detail_screen.dart
    profile/     profile_screen.dart
test/            widget_test.dart
```

## How to Run

```bash
flutter create .          # generates android/ ios/ web/ platform folders (first time only)
flutter pub get
flutter run
```

## Future Enhancements

- Charts for spending by category
- Export to CSV or PDF
- Budget limits with alerts
- Firebase authentication and cloud sync
- Dark mode

## Developed By

<Your Name> — <Roll Number>, <Department>
