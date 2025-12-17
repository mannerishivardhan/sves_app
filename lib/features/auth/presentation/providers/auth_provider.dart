import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

part 'auth_provider.g.dart';

/// Provider for auth repository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}

/// Provider for Firebase Auth state
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Provider for current user profile
@riverpod
Stream<UserModel?> currentUserProfile(CurrentUserProfileRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUserProfileStream;
}

/// Auth controller for authentication actions - NO STATE MANAGEMENT
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<void> build() async {
    // No state to initialize
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('🔑 AUTH PROVIDER: signIn called');
    debugPrint('🔑 AUTH PROVIDER: Email: $email');

    try {
      final authRepository = ref.read(authRepositoryProvider);
      debugPrint(
        '🔑 AUTH PROVIDER: Calling repository signInWithEmailPassword...',
      );

      final user = await authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      debugPrint('🔑 AUTH PROVIDER: Sign in successful! User: ${user.email}');
      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ AUTH PROVIDER ERROR: $e');
      debugPrint('❌ AUTH PROVIDER STACK: $stackTrace');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
  }
}
