import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/department_repository.dart';
import '../../data/models/department_model.dart';

part 'department_provider.g.dart';

/// Provider for department repository
@riverpod
DepartmentRepository departmentRepository(DepartmentRepositoryRef ref) {
  return DepartmentRepository();
}

/// Stream provider for all departments
@riverpod
Stream<List<DepartmentModel>> departmentsStream(DepartmentsStreamRef ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return repository.getDepartmentsStream();
}

/// Stream provider for active departments only
@riverpod
Stream<List<DepartmentModel>> activeDepartmentsStream(
  ActiveDepartmentsStreamRef ref,
) {
  final repository = ref.watch(departmentRepositoryProvider);
  return repository.getActiveDepartmentsStream();
}

/// Stream provider for a single department by ID
@riverpod
Stream<DepartmentModel?> departmentStream(
  DepartmentStreamRef ref,
  String departmentId,
) {
  final repository = ref.watch(departmentRepositoryProvider);
  return repository.getDepartmentStream(departmentId);
}

/// Controller for department operations
@riverpod
class DepartmentController extends _$DepartmentController {
  @override
  FutureOr<void> build() {
    // Initialize
  }

  /// Create a new department
  Future<String> createDepartment({
    required String name,
    required String description,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(departmentRepositoryProvider);
      final departmentId = await repository.createDepartment(
        name: name,
        description: description,
      );

      state = const AsyncValue.data(null);
      return departmentId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Update department
  Future<void> updateDepartment({
    required String departmentId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(departmentRepositoryProvider);
      await repository.updateDepartment(
        departmentId: departmentId,
        name: name,
        description: description,
        isActive: isActive,
      );

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Assign department head
  Future<void> assignHead({
    required String departmentId,
    required String headId,
    required String headName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(departmentRepositoryProvider);
      await repository.assignDepartmentHead(
        departmentId: departmentId,
        headId: headId,
        headName: headName,
      );

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Delete department
  Future<void> deleteDepartment(String departmentId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(departmentRepositoryProvider);
      await repository.deleteDepartment(departmentId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Recalculate all department member counts
  /// Use this to fix counts if they get out of sync
  Future<void> recalculateDepartmentCounts() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(departmentRepositoryProvider);
      await repository.recalculateAllDepartmentCounts();

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
