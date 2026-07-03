// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskSuggestionsHash() => r'254f5c9a573758a539bf799b9abe2634dca9d20b';

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

/// See also [taskSuggestions].
@ProviderFor(taskSuggestions)
const taskSuggestionsProvider = TaskSuggestionsFamily();

/// See also [taskSuggestions].
class TaskSuggestionsFamily extends Family<AsyncValue<List<TaskTemplate>>> {
  /// See also [taskSuggestions].
  const TaskSuggestionsFamily();

  /// See also [taskSuggestions].
  TaskSuggestionsProvider call(
    Spot spot,
    Persona persona,
  ) {
    return TaskSuggestionsProvider(
      spot,
      persona,
    );
  }

  @override
  TaskSuggestionsProvider getProviderOverride(
    covariant TaskSuggestionsProvider provider,
  ) {
    return call(
      provider.spot,
      provider.persona,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskSuggestionsProvider';
}

/// See also [taskSuggestions].
class TaskSuggestionsProvider
    extends AutoDisposeFutureProvider<List<TaskTemplate>> {
  /// See also [taskSuggestions].
  TaskSuggestionsProvider(
    Spot spot,
    Persona persona,
  ) : this._internal(
          (ref) => taskSuggestions(
            ref as TaskSuggestionsRef,
            spot,
            persona,
          ),
          from: taskSuggestionsProvider,
          name: r'taskSuggestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskSuggestionsHash,
          dependencies: TaskSuggestionsFamily._dependencies,
          allTransitiveDependencies:
              TaskSuggestionsFamily._allTransitiveDependencies,
          spot: spot,
          persona: persona,
        );

  TaskSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.spot,
    required this.persona,
  }) : super.internal();

  final Spot spot;
  final Persona persona;

  @override
  Override overrideWith(
    FutureOr<List<TaskTemplate>> Function(TaskSuggestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskSuggestionsProvider._internal(
        (ref) => create(ref as TaskSuggestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        spot: spot,
        persona: persona,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskTemplate>> createElement() {
    return _TaskSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskSuggestionsProvider &&
        other.spot == spot &&
        other.persona == persona;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, spot.hashCode);
    hash = _SystemHash.combine(hash, persona.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TaskSuggestionsRef on AutoDisposeFutureProviderRef<List<TaskTemplate>> {
  /// The parameter `spot` of this provider.
  Spot get spot;

  /// The parameter `persona` of this provider.
  Persona get persona;
}

class _TaskSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskTemplate>>
    with TaskSuggestionsRef {
  _TaskSuggestionsProviderElement(super.provider);

  @override
  Spot get spot => (origin as TaskSuggestionsProvider).spot;
  @override
  Persona get persona => (origin as TaskSuggestionsProvider).persona;
}

String _$taskNotifierHash() => r'969367896f675db12bdc3fc62bbb21a2175fe812';

abstract class _$TaskNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Task>> {
  late final int journeyId;

  FutureOr<List<Task>> build(
    int journeyId,
  );
}

/// See also [TaskNotifier].
@ProviderFor(TaskNotifier)
const taskNotifierProvider = TaskNotifierFamily();

/// See also [TaskNotifier].
class TaskNotifierFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [TaskNotifier].
  const TaskNotifierFamily();

  /// See also [TaskNotifier].
  TaskNotifierProvider call(
    int journeyId,
  ) {
    return TaskNotifierProvider(
      journeyId,
    );
  }

  @override
  TaskNotifierProvider getProviderOverride(
    covariant TaskNotifierProvider provider,
  ) {
    return call(
      provider.journeyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskNotifierProvider';
}

/// See also [TaskNotifier].
class TaskNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TaskNotifier, List<Task>> {
  /// See also [TaskNotifier].
  TaskNotifierProvider(
    int journeyId,
  ) : this._internal(
          () => TaskNotifier()..journeyId = journeyId,
          from: taskNotifierProvider,
          name: r'taskNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskNotifierHash,
          dependencies: TaskNotifierFamily._dependencies,
          allTransitiveDependencies:
              TaskNotifierFamily._allTransitiveDependencies,
          journeyId: journeyId,
        );

  TaskNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.journeyId,
  }) : super.internal();

  final int journeyId;

  @override
  FutureOr<List<Task>> runNotifierBuild(
    covariant TaskNotifier notifier,
  ) {
    return notifier.build(
      journeyId,
    );
  }

  @override
  Override overrideWith(TaskNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TaskNotifierProvider._internal(
        () => create()..journeyId = journeyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        journeyId: journeyId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TaskNotifier, List<Task>>
      createElement() {
    return _TaskNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskNotifierProvider && other.journeyId == journeyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, journeyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TaskNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Task>> {
  /// The parameter `journeyId` of this provider.
  int get journeyId;
}

class _TaskNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TaskNotifier, List<Task>>
    with TaskNotifierRef {
  _TaskNotifierProviderElement(super.provider);

  @override
  int get journeyId => (origin as TaskNotifierProvider).journeyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
