import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

part 'user_provider.g.dart';

/// Provider for user repository
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository();
}

/// Stream provider for all users
@riverpod
Stream<List<UserModel>> usersStream(UsersStreamRef ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersStream();
}

/// Stream provider for users by department
@riverpod
Stream<List<UserModel>> usersByDepartmentStream(
  UsersByDepartmentStreamRef ref,
  String departmentId,
) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByDepartmentStream(departmentId);
}

/// Stream provider for users by role
@riverpod
Stream<List<UserModel>> usersByRoleStream(
  UsersByRoleStreamRef ref,
  String role,
) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRoleStream(role);
}

/// Stream provider for users by both department and role
@riverpod
Stream<List<UserModel>> usersByDepartmentAndRoleStream(
  UsersByDepartmentAndRoleStreamRef ref,
  String departmentId,
  String role,
) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByDepartmentAndRoleStream(departmentId, role);
}

/// Controller for user operations
@riverpod
class UserController extends _$UserController {
  @override
  FutureOr<void> build() {
    // Initialize
  }

  /// Create a new user
  Future<String> createUser({
    required String employeeId,
    required String email,
    required String name,
    required String phone,
    required String role,
    String? departmentId,
    String password = 'Password@123',
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      final userId = await repository.createUser(
        employeeId: employeeId,
        email: email,
        name: name,
        phone: phone,
        role: role,
        departmentId: departmentId,
        password: password,
      );

      state = const AsyncValue.data(null);
      return userId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Update user
  Future<void> updateUser({
    required String userId,
    String? name,
    String? phone,
    String? role,
    String? departmentId,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateUser(
        userId: userId,
        name: name,
        phone: phone,
        role: role,
        departmentId: departmentId,
        isActive: isActive,
      );

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(String userId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.deactivateUser(userId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Activate user
  Future<void> activateUser(String userId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.activateUser(userId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Permanently delete user
  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.deleteUser(userId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Transfer user to different department
  Future<void> transferUser({
    required String userId,
    required String newDepartmentId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.transferUser(
        userId: userId,
        newDepartmentId: newDepartmentId,
      );

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.resetUserPassword(email: email);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
