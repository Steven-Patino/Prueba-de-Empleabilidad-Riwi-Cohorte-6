# EcoDelivery - Flutter app

Mobile app for EcoDelivery clients and couriers. It consumes the REST API from the
`backend/` module. There is no hard-coded data: every screen calls the API.

## Screens

- **Login** (`login_screen.dart`): green gradient background, animated logo, an elevated
  card with a username field (required) and an optional API key. The API key, if given, is
  sent as `X-API-Key` on write calls; the username is kept for the session and shown in
  the list header. A logout button on the list clears the session and returns here.
- **Orders list** (`pedidos_list_screen.dart`): `GET /pedidos` inside a `CustomScrollView`
  with an expandable `SliverAppBar` (greeting + summary chips). Status/zone filters as
  animated chip rows. Each order is a card with a colored status icon, client, zone, id,
  amount and a `Hero` status pill. Staggered entrance animation, pulsing skeleton cards
  while loading, illustrated empty / error states, pull-to-refresh, extended FAB.
- **Order detail** (`pedido_detail_screen.dart`): `GET /pedidos/:id`. Colored header, a
  **status timeline** (`pendiente → en_camino → entregado`) with the current step
  highlighted, detail cards with icon rows, and an animated "advance status" button
  (`PATCH /pedidos/:id/estado`) coloured by the next state; a banner for final states.
- **Create order** (`crear_pedido_screen.dart`): sectioned form; zone and payment method
  as selectable chips, `$`-prefixed amount field, validation, animated submit button,
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

Pick the `API_BASE_URL` that matches where you run the app. The backend is published on
host port **8010** (`API_HOST_PORT` in `.env`; container port is still 8000).

| Target                | API_BASE_URL                 |
|-----------------------|------------------------------|
| Android emulator      | `http://10.0.2.2:8010`       |
| iOS simulator         | `http://localhost:8010`      |
| Chrome / Flutter web  | `http://localhost:8010`      |
| Physical phone        | `http://<your-pc-ip>:8010`   |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8010
```

If you enabled the optional API key in the backend, either type it on the login screen or
pass it at build time:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8010 \
  --dart-define=API_KEY=my-secret-key
```

## Notes

- Material 3 theme centralised in `lib/theme.dart` (green palette). Shared visual widgets
  in `lib/widgets/ui.dart`. Animations use only the Flutter SDK — no extra packages
  (deps stay `http` + `provider`).
- `flutter analyze` is clean and `flutter build web` succeeds.
- State management uses `provider`: `AuthProvider` (session) and `PedidosProvider`
  (exposes `idle / loading / error / loaded` states).
- Both optional extras are implemented: the login screen and pull-to-refresh on the list.
- The login is lightweight (no user table in the backend); it captures the session
  username and the optional API key, consistent with the backend's optional-API-key auth.
- Verified running against the dockerized API (Flutter web / Chrome). On web use
  `http://localhost:8010` — `10.0.2.2` only resolves from the Android emulator.
- The app↔API contract was also checked statically: the 4 calls in `api_service.dart`
  match the backend routes, and `Pedido.fromJson` parses exactly the fields the API
  returns.
