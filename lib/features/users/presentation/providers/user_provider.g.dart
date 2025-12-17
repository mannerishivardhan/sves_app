// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositoryHash() => r'f57c5c0b9b0485125e28199e7485d48a63f8ef70';

/// Provider for user repository
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$usersStreamHash() => r'a14dcff615404845fcb7748ca9b48a724ee8437c';

/// Stream provider for all users
///
/// Copied from [usersStream].
@ProviderFor(usersStream)
final usersStreamProvider = AutoDisposeStreamProvider<List<UserModel>>.internal(
  usersStream,
  name: r'usersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UsersStreamRef = AutoDisposeStreamProviderRef<List<UserModel>>;
String _$usersByDepartmentStreamHash() =>
    r'7e0d2f961fe1c64a28ba16c466f86b49d10c65b7';

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

/// Stream provider for users by department
///
/// Copied from [usersByDepartmentStream].
@ProviderFor(usersByDepartmentStream)
const usersByDepartmentStreamProvider = UsersByDepartmentStreamFamily();

/// Stream provider for users by department
///
/// Copied from [usersByDepartmentStream].
class UsersByDepartmentStreamFamily
    extends Family<AsyncValue<List<UserModel>>> {
  /// Stream provider for users by department
  ///
  /// Copied from [usersByDepartmentStream].
  const UsersByDepartmentStreamFamily();

  /// Stream provider for users by department
  ///
  /// Copied from [usersByDepartmentStream].
  UsersByDepartmentStreamProvider call(String departmentId) {
    return UsersByDepartmentStreamProvider(departmentId);
  }

  @override
  UsersByDepartmentStreamProvider getProviderOverride(
    covariant UsersByDepartmentStreamProvider provider,
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
  String? get name => r'usersByDepartmentStreamProvider';
}

/// Stream provider for users by department
///
/// Copied from [usersByDepartmentStream].
class UsersByDepartmentStreamProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Stream provider for users by department
  ///
  /// Copied from [usersByDepartmentStream].
  UsersByDepartmentStreamProvider(String departmentId)
    : this._internal(
        (ref) => usersByDepartmentStream(
          ref as UsersByDepartmentStreamRef,
          departmentId,
        ),
        from: usersByDepartmentStreamProvider,
        name: r'usersByDepartmentStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usersByDepartmentStreamHash,
        dependencies: UsersByDepartmentStreamFamily._dependencies,
        allTransitiveDependencies:
            UsersByDepartmentStreamFamily._allTransitiveDependencies,
        departmentId: departmentId,
      );

  UsersByDepartmentStreamProvider._internal(
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
    Stream<List<UserModel>> Function(UsersByDepartmentStreamRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersByDepartmentStreamProvider._internal(
        (ref) => create(ref as UsersByDepartmentStreamRef),
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
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _UsersByDepartmentStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByDepartmentStreamProvider &&
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
mixin UsersByDepartmentStreamRef
    on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `departmentId` of this provider.
  String get departmentId;
}

class _UsersByDepartmentStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with UsersByDepartmentStreamRef {
  _UsersByDepartmentStreamProviderElement(super.provider);

  @override
  String get departmentId =>
      (origin as UsersByDepartmentStreamProvider).departmentId;
}

String _$usersByRoleStreamHash() => r'25ee6b782d10a3629877c166fd7764241201c265';

/// Stream provider for users by role
///
/// Copied from [usersByRoleStream].
@ProviderFor(usersByRoleStream)
const usersByRoleStreamProvider = UsersByRoleStreamFamily();

/// Stream provider for users by role
///
/// Copied from [usersByRoleStream].
class UsersByRoleStreamFamily extends Family<AsyncValue<List<UserModel>>> {
  /// Stream provider for users by role
  ///
  /// Copied from [usersByRoleStream].
  const UsersByRoleStreamFamily();

  /// Stream provider for users by role
  ///
  /// Copied from [usersByRoleStream].
  UsersByRoleStreamProvider call(String role) {
    return UsersByRoleStreamProvider(role);
  }

  @override
  UsersByRoleStreamProvider getProviderOverride(
    covariant UsersByRoleStreamProvider provider,
  ) {
    return call(provider.role);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usersByRoleStreamProvider';
}

/// Stream provider for users by role
///
/// Copied from [usersByRoleStream].
class UsersByRoleStreamProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Stream provider for users by role
  ///
  /// Copied from [usersByRoleStream].
  UsersByRoleStreamProvider(String role)
    : this._internal(
        (ref) => usersByRoleStream(ref as UsersByRoleStreamRef, role),
        from: usersByRoleStreamProvider,
        name: r'usersByRoleStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usersByRoleStreamHash,
        dependencies: UsersByRoleStreamFamily._dependencies,
        allTransitiveDependencies:
            UsersByRoleStreamFamily._allTransitiveDependencies,
        role: role,
      );

  UsersByRoleStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final String role;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(UsersByRoleStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersByRoleStreamProvider._internal(
        (ref) => create(ref as UsersByRoleStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _UsersByRoleStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByRoleStreamProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsersByRoleStreamRef on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `role` of this provider.
  String get role;
}

class _UsersByRoleStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with UsersByRoleStreamRef {
  _UsersByRoleStreamProviderElement(super.provider);

  @override
  String get role => (origin as UsersByRoleStreamProvider).role;
}

String _$usersByDepartmentAndRoleStreamHash() =>
    r'1d2bccc57b63f1831481c9953ea444c76cfac6b6';

/// Stream provider for users by both department and role
///
/// Copied from [usersByDepartmentAndRoleStream].
@ProviderFor(usersByDepartmentAndRoleStream)
const usersByDepartmentAndRoleStreamProvider =
    UsersByDepartmentAndRoleStreamFamily();

/// Stream provider for users by both department and role
///
/// Copied from [usersByDepartmentAndRoleStream].
class UsersByDepartmentAndRoleStreamFamily
    extends Family<AsyncValue<List<UserModel>>> {
  /// Stream provider for users by both department and role
  ///
  /// Copied from [usersByDepartmentAndRoleStream].
  const UsersByDepartmentAndRoleStreamFamily();

  /// Stream provider for users by both department and role
  ///
  /// Copied from [usersByDepartmentAndRoleStream].
  UsersByDepartmentAndRoleStreamProvider call(
    String departmentId,
    String role,
  ) {
    return UsersByDepartmentAndRoleStreamProvider(departmentId, role);
  }

  @override
  UsersByDepartmentAndRoleStreamProvider getProviderOverride(
    covariant UsersByDepartmentAndRoleStreamProvider provider,
  ) {
    return call(provider.departmentId, provider.role);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usersByDepartmentAndRoleStreamProvider';
}

/// Stream provider for users by both department and role
///
/// Copied from [usersByDepartmentAndRoleStream].
class UsersByDepartmentAndRoleStreamProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Stream provider for users by both department and role
  ///
  /// Copied from [usersByDepartmentAndRoleStream].
  UsersByDepartmentAndRoleStreamProvider(String departmentId, String role)
    : this._internal(
        (ref) => usersByDepartmentAndRoleStream(
          ref as UsersByDepartmentAndRoleStreamRef,
          departmentId,
          role,
        ),
        from: usersByDepartmentAndRoleStreamProvider,
        name: r'usersByDepartmentAndRoleStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usersByDepartmentAndRoleStreamHash,
        dependencies: UsersByDepartmentAndRoleStreamFamily._dependencies,
        allTransitiveDependencies:
            UsersByDepartmentAndRoleStreamFamily._allTransitiveDependencies,
        departmentId: departmentId,
        role: role,
      );

  UsersByDepartmentAndRoleStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
    required this.role,
  }) : super.internal();

  final String departmentId;
  final String role;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(UsersByDepartmentAndRoleStreamRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersByDepartmentAndRoleStreamProvider._internal(
        (ref) => create(ref as UsersByDepartmentAndRoleStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _UsersByDepartmentAndRoleStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByDepartmentAndRoleStreamProvider &&
        other.departmentId == departmentId &&
        other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsersByDepartmentAndRoleStreamRef
    on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `departmentId` of this provider.
  String get departmentId;

  /// The parameter `role` of this provider.
  String get role;
}

class _UsersByDepartmentAndRoleStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with UsersByDepartmentAndRoleStreamRef {
  _UsersByDepartmentAndRoleStreamProviderElement(super.provider);

  @override
  String get departmentId =>
      (origin as UsersByDepartmentAndRoleStreamProvider).departmentId;
  @override
  String get role => (origin as UsersByDepartmentAndRoleStreamProvider).role;
}

String _$userControllerHash() => r'21c26124bf92e72436098f68d243fb39aab2e4ae';

/// Controller for user operations
///
/// Copied from [UserController].
@ProviderFor(UserController)
final userControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserController, void>.internal(
      UserController.new,
      name: r'userControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
