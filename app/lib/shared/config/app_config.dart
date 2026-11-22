/// Configuración que llega al compilar con `--dart-define`.
abstract final class AppConfig {
  /// URL del backend. Por defecto apunta a la PC desde el emulador de Android.
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8800',
  );
}
