/// Build-time environment. Defaults to dev — no API keys or sign-in needed.
/// Production build: flutter run --dart-define=ENV=prod
const appEnv = String.fromEnvironment('ENV', defaultValue: 'dev');
const isDev = appEnv == 'dev';
