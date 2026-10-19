/// Compile-time demo mode, for previewing the dashboard without signing in:
///
///   flutter run -d chrome --dart-define=DEMO=true
///   flutter build web --release --dart-define=DEMO=true
///
/// When true the auth gate is skipped, Firebase is never initialised and
/// every feature reads and writes in-memory mock data. Release builds (CI)
/// never set it, so production behaviour is unchanged.
const bool demoMode = bool.fromEnvironment('DEMO');
