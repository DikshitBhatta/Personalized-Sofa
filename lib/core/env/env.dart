class Env {
  // DEV ONLY: pass key via --dart-define=MESHY_KEY=your_key
  // For testing builds we provide a temporary public key fallback.
  // IMPORTANT: This key is for testing only. Do NOT commit a production key.
  // Replace or remove before production release.
  // NOTE: TESTING ONLY - temporary hardcoded API key as requested.
  // Remove or replace with a secure mechanism before shipping.
  static const _publicTestKey = 'msy_r1WI6CuPrJNhcIj7mX3tWtTN5W9PHTUd0wmc';

  // Prefer compile-time dart-define, but fall back to the public test key when empty.
  static String get meshyKey {
  const fromEnv = String.fromEnvironment('MESHY_KEY');
  if (fromEnv.isNotEmpty) return fromEnv;
    return _publicTestKey;
  }

  static const meshyBase = 'https://api.meshy.ai';
}
