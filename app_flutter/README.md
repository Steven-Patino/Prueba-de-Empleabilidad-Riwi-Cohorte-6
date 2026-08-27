# EcoDelivery - Flutter app

Mobile app for EcoDelivery clients and couriers. It consumes the REST API from the
`backend/` module. There is no hard-coded data: every screen calls the API.

## Screens

- **Login** (`login_screen.dart`): simple sign-in screen. Asks for a username (required)
  and an optional API key. The API key, if given, is sent as `X-API-Key` on write calls;
  the username is kept for the session and shown in the app bar. A logout button on the
  orders list clears the session and returns here.
- **Orders list** (`pedidos_list_screen.dart`): calls `GET /pedidos`, shows client, zone,
  a colored status chip and the amount. Filters by status and by zone. Pull-to-refresh
  and a loading spinner / error panel with retry are included.
- **Order detail** (`pedido_detail_screen.dart`): calls `GET /pedidos/:id`, shows all the
  fields and a button that advances the status (`pendiente -> en_camino -> entregado`)
  by calling `PATCH /pedidos/:id/estado`.
- **Create order** (`crear_pedido_screen.dart`): form with basic validation that calls
  `POST /pedidos`.

## Requirements

- Flutter SDK 3.x (stable channel). Check with `flutter --version`.
- The backend running and reachable (see the root `README.md`, `docker compose up`).

## First time setup

This folder contains only `lib/`, `pubspec.yaml` and config files. Generate the platform
folders (android, ios, web, ...) once:

```bash
cd app_flutter
flutter create .
flutter pub get
```

## Run

Pick the `API_BASE_URL` that matches where you run the app. The backend listens on port
8000.

| Target                | API_BASE_URL                 |
|-----------------------|------------------------------|
| Android emulator      | `http://10.0.2.2:8000`       |
| iOS simulator         | `http://localhost:8000`      |
| Chrome / Flutter web  | `http://localhost:8000`      |
| Physical phone        | `http://<your-pc-ip>:8000`   |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

If you enabled the optional API key in the backend, either type it on the login screen or
pass it at build time:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=API_KEY=my-secret-key
```

## Notes

- State management uses `provider`: `AuthProvider` (session) and `PedidosProvider`
  (exposes `idle / loading / error / loaded` states).
- Both optional extras are implemented: the login screen and pull-to-refresh on the list.
- The login is lightweight (no user table in the backend); it captures the session
  username and the optional API key, consistent with the backend's optional-API-key auth.
