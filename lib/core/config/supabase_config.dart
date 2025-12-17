import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    final supabaseServiceKey = dotenv.env['SUPABASE_SERVICE_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Missing Supabase credentials. Please check your .env file.\n'
        'Required: SUPABASE_URL and SUPABASE_ANON_KEY',
      );
    }

    // Use Service Role Key if available for admin operations
    final keyToUse = supabaseServiceKey ?? supabaseAnonKey;

    logger.i(
      '🔑 Initializing Supabase with ${supabaseServiceKey != null ? "Service Role Key" : "Anon Key"}',
    );

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: keyToUse,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Initialize Admin Client (Service Role) - strictly for admin ops
    if (supabaseServiceKey != null) {
      _adminClient = SupabaseClient(
        supabaseUrl,
        supabaseServiceKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      logger.i('🔐 Admin Client initialized with Service Role Key');
    } else {
      logger.w('⚠️ No Service Role Key found. Admin operations might fail.');
      _adminClient =
          Supabase.instance.client; // Fallback (will likely fail RLS)
    }
  }

  static late final SupabaseClient _adminClient;
  static SupabaseClient get client => Supabase.instance.client;
  static SupabaseClient get adminClient => _adminClient;
}
