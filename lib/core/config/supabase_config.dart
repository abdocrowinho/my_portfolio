// Provides compile-time Supabase configuration without committing credentials to source control.
abstract final class SupabaseConfig {
  static const projectUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pwnqxzvtoyjnuyjiucuo.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3bnF4enZ0b3lqbnV5aml1Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3ODE5NjUsImV4cCI6MjEwMzM1Nzk2NX0.YoszqyKpFMnQe_ybpLK_Pex4oLGVKOxbwj1rfLX4_1A',
  );

  static bool get hasCredentials => anonKey.isNotEmpty;
}
