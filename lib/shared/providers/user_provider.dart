import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rider34/shared/models/user_model.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;
  if (session == null) return null;

  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .single();

    // 'profiles' table has no email column — pull it from the auth session
    final data = Map<String, dynamic>.from(response);
    data['email'] = session.user.email ?? '';

    return UserModel.fromJson(data);
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
});
