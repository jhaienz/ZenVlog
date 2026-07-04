// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedNotifierHash() => r'9237c3570417e88577cbb71d4308ad53ae8703ad';

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

abstract class _$FeedNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Post>> {
  late final FeedTab tab;

  FutureOr<List<Post>> build(
    FeedTab tab,
  );
}

/// See also [FeedNotifier].
@ProviderFor(FeedNotifier)
const feedNotifierProvider = FeedNotifierFamily();

/// See also [FeedNotifier].
class FeedNotifierFamily extends Family<AsyncValue<List<Post>>> {
  /// See also [FeedNotifier].
  const FeedNotifierFamily();

  /// See also [FeedNotifier].
  FeedNotifierProvider call(
    FeedTab tab,
  ) {
    return FeedNotifierProvider(
      tab,
    );
  }

  @override
  FeedNotifierProvider getProviderOverride(
    covariant FeedNotifierProvider provider,
  ) {
    return call(
      provider.tab,
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
  String? get name => r'feedNotifierProvider';
}

/// See also [FeedNotifier].
class FeedNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<FeedNotifier, List<Post>> {
  /// See also [FeedNotifier].
  FeedNotifierProvider(
    FeedTab tab,
  ) : this._internal(
          () => FeedNotifier()..tab = tab,
          from: feedNotifierProvider,
          name: r'feedNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedNotifierHash,
          dependencies: FeedNotifierFamily._dependencies,
          allTransitiveDependencies:
              FeedNotifierFamily._allTransitiveDependencies,
          tab: tab,
        );

  FeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tab,
  }) : super.internal();

  final FeedTab tab;

  @override
  FutureOr<List<Post>> runNotifierBuild(
    covariant FeedNotifier notifier,
  ) {
    return notifier.build(
      tab,
    );
  }

  @override
  Override overrideWith(FeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedNotifierProvider._internal(
        () => create()..tab = tab,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tab: tab,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FeedNotifier, List<Post>>
      createElement() {
    return _FeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedNotifierProvider && other.tab == tab;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tab.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FeedNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Post>> {
  /// The parameter `tab` of this provider.
  FeedTab get tab;
}

class _FeedNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FeedNotifier, List<Post>>
    with FeedNotifierRef {
  _FeedNotifierProviderElement(super.provider);

  @override
  FeedTab get tab => (origin as FeedNotifierProvider).tab;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
