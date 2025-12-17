// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$departmentRepositoryHash() =>
    r'8b7f6e9f0293bae99d77033aa074cdb0f01fc4a1';

/// Provider for department repository
///
/// Copied from [departmentRepository].
@ProviderFor(departmentRepository)
final departmentRepositoryProvider =
    AutoDisposeProvider<DepartmentRepository>.internal(
      departmentRepository,
      name: r'departmentRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$departmentRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DepartmentRepositoryRef = AutoDisposeProviderRef<DepartmentRepository>;
String _$departmentsStreamHash() => r'90752140aed040811d199368da66a2ce9bce3209';

/// Stream provider for all departments
///
/// Copied from [departmentsStream].
@ProviderFor(departmentsStream)
final departmentsStreamProvider =
    AutoDisposeStreamProvider<List<DepartmentModel>>.internal(
      departmentsStream,
      name: r'departmentsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$departmentsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DepartmentsStreamRef =
    AutoDisposeStreamProviderRef<List<DepartmentModel>>;
String _$activeDepartmentsStreamHash() =>
    r'34fb9e4ff3ff128b5a1e6364d094f80d5916600c';

/// Stream provider for active departments only
///
/// Copied from [activeDepartmentsStream].
@ProviderFor(activeDepartmentsStream)
final activeDepartmentsStreamProvider =
    AutoDisposeStreamProvider<List<DepartmentModel>>.internal(
      activeDepartmentsStream,
      name: r'activeDepartmentsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeDepartmentsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveDepartmentsStreamRef =
    AutoDisposeStreamProviderRef<List<DepartmentModel>>;
String _$departmentStreamHash() => r'1c599daad720a91d395930e7c1781de27a9ef3fb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Stream provider for a single department by ID
///
/// Copied from [departmentStream].
@ProviderFor(departmentStream)
const departmentStreamProvider = DepartmentStreamFamily();

/// Stream provider for a single department by ID
///
/// Copied from [departmentStream].
class DepartmentStreamFamily extends Family<AsyncValue<DepartmentModel?>> {
  /// Stream provider for a single department by ID
  ///
  /// Copied from [departmentStream].
  const DepartmentStreamFamily();

  /// Stream provider for a single department by ID
  ///
  /// Copied from [departmentStream].
  DepartmentStreamProvider call(String departmentId) {
    return DepartmentStreamProvider(departmentId);
  }

  @override
  DepartmentStreamProvider getProviderOverride(
    covariant DepartmentStreamProvider provider,
  ) {
    return call(provider.departmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'departmentStreamProvider';
}

/// Stream provider for a single department by ID
///
/// Copied from [departmentStream].
class DepartmentStreamProvider
    extends AutoDisposeStreamProvider<DepartmentModel?> {
  /// Stream provider for a single department by ID
  ///
  /// Copied from [departmentStream].
  DepartmentStreamProvider(String departmentId)
    : this._internal(
        (ref) => departmentStream(ref as DepartmentStreamRef, departmentId),
        from: departmentStreamProvider,
        name: r'departmentStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$departmentStreamHash,
        dependencies: DepartmentStreamFamily._dependencies,
        allTransitiveDependencies:
            DepartmentStreamFamily._allTransitiveDependencies,
        departmentId: departmentId,
      );

  DepartmentStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
  }) : super.internal();

  final String departmentId;

  @override
  Override overrideWith(
    Stream<DepartmentModel?> Function(DepartmentStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DepartmentStreamProvider._internal(
        (ref) => create(ref as DepartmentStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DepartmentModel?> createElement() {
    return _DepartmentStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DepartmentStreamProvider &&
        other.departmentId == departmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DepartmentStreamRef on AutoDisposeStreamProviderRef<DepartmentModel?> {
  /// The parameter `departmentId` of this provider.
  String get departmentId;
}

class _DepartmentStreamProviderElement
    extends AutoDisposeStreamProviderElement<DepartmentModel?>
    with DepartmentStreamRef {
  _DepartmentStreamProviderElement(super.provider);

  @override
  String get departmentId => (origin as DepartmentStreamProvider).departmentId;
}

String _$departmentControllerHash() =>
    r'676428a4bcb9e865613d6d4704683f6d9c73a02a';

/// Controller for department operations
///
/// Copied from [DepartmentController].
@ProviderFor(DepartmentController)
final departmentControllerProvider =
    AutoDisposeAsyncNotifierProvider<DepartmentController, void>.internal(
      DepartmentController.new,
      name: r'departmentControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$departmentControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DepartmentController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
