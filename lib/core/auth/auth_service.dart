import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_env.dart';
import '../env.dart';

class AuthService {
  static bool _initialized = false;

  /// Test seam: set in widget tests to bypass Supabase entirely.
  static bool? debugSignedInOverride;

  static Future<void> initialize() async {
    if (_initialized || isDev) return; // dev: no Supabase, no keys needed
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
    _initialized = true;
  }

  static bool get isSignedIn {
    if (debugSignedInOverride != null) return debugSignedInOverride!;
    if (isDev) return true; // dev: auth bypassed entirely
    if (!_initialized) return false;
    return Supabase.instance.client.auth.currentSession != null;
  }

  /// The user's identity everywhere (Group sync, feed, journal ownership).
  static String get userId =>
      isDev ? 'dev-user' : Supabase.instance.client.auth.currentUser!.id;

  static Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password) async {
    await Supabase.instance.client.auth
        .signUp(email: email, password: password);
  }

  static Future<void> signOut() =>
      Supabase.instance.client.auth.signOut();
}
