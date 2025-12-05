# Fi El Sekka Admin Dashboard

Admin dashboard for Fi El Sekka transportation application built with Flutter Web.

## Features

- ✅ Admin Authentication (Supabase)
- ✅ Material Design 3 Theme
- ✅ Responsive Layout
- ✅ GoRouter Navigation
- 🚧 Dashboard Home (Coming Soon)
- 🚧 Users Management (Coming Soon)
- 🚧 Subscriptions Management (Coming Soon)
- 🚧 Trips & Schedules (Coming Soon)

## Tech Stack

- **Framework**: Flutter Web
- **Backend**: Supabase
- **State Management**: Riverpod
- **Routing**: GoRouter
- **UI**: Material Design 3 + FlexColorScheme
- **Charts**: fl_chart
- **Tables**: data_table_2

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd dashboard_fi_el_sekka
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Update `.env` with your Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

5. Run the app:
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── core/
│   ├── config/          # Supabase & Router config
│   ├── theme/           # App theme
│   └── widgets/         # Shared widgets
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Dashboard home
│   ├── users/           # Users management
│   ├── subscriptions/   # Subscriptions
│   └── trips/           # Trips & schedules
└── main.dart
```

## Admin Login

Create an admin user in Supabase:

1. Go to Authentication → Users → Add User
2. Set `user_type` to `'admin'` in the `users` table
3. Login with the credentials

## License

Private project - All rights reserved
