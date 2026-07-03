// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anshin_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$anshinAlertsHash() => r'f01c63eb3ddb27bc3c30aaeea243b19029afa4ef';

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

/// The Anshin Engine: merges pre-cached forecast, static hazard zones,
/// and (where the device has one) barometer pressure trend into a stream
/// of alerts for the active journey position.
///
/// Copied from [anshinAlerts].
@ProviderFor(anshinAlerts)
const anshinAlertsProvider = AnshinAlertsFamily();

/// The Anshin Engine: merges pre-cached forecast, static hazard zones,
/// and (where the device has one) barometer pressure trend into a stream
/// of alerts for the active journey position.
///
/// Copied from [anshinAlerts].
class AnshinAlertsFamily extends Family<AsyncValue<List<AnshinAlert>>> {
  /// The Anshin Engine: merges pre-cached forecast, static hazard zones,
  /// and (where the device has one) barometer pressure trend into a stream
  /// of alerts for the active journey position.
  ///
  /// Copied from [anshinAlerts].
  const AnshinAlertsFamily();

  /// The Anshin Engine: merges pre-cached forecast, static hazard zones,
  /// and (where the device has one) barometer pressure trend into a stream
  /// of alerts for the active journey position.
  ///
  /// Copied from [anshinAlerts].
  AnshinAlertsProvider call(
    double lat,
    double lng,
  ) {
    return AnshinAlertsProvider(
      lat,
      lng,
    );
  }

  @override
  AnshinAlertsProvider getProviderOverride(
    covariant AnshinAlertsProvider provider,
  ) {
    return call(
      provider.lat,
      provider.lng,
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
  String? get name => r'anshinAlertsProvider';
}

/// The Anshin Engine: merges pre-cached forecast, static hazard zones,
/// and (where the device has one) barometer pressure trend into a stream
/// of alerts for the active journey position.
///
/// Copied from [anshinAlerts].
class AnshinAlertsProvider
    extends AutoDisposeStreamProvider<List<AnshinAlert>> {
  /// The Anshin Engine: merges pre-cached forecast, static hazard zones,
  /// and (where the device has one) barometer pressure trend into a stream
  /// of alerts for the active journey position.
  ///
  /// Copied from [anshinAlerts].
  AnshinAlertsProvider(
    double lat,
    double lng,
  ) : this._internal(
          (ref) => anshinAlerts(
            ref as AnshinAlertsRef,
            lat,
            lng,
          ),
          from: anshinAlertsProvider,
          name: r'anshinAlertsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$anshinAlertsHash,
          dependencies: AnshinAlertsFamily._dependencies,
          allTransitiveDependencies:
              AnshinAlertsFamily._allTransitiveDependencies,
          lat: lat,
          lng: lng,
        );

  AnshinAlertsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lat,
    required this.lng,
  }) : super.internal();

  final double lat;
  final double lng;

  @override
  Override overrideWith(
    Stream<List<AnshinAlert>> Function(AnshinAlertsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnshinAlertsProvider._internal(
        (ref) => create(ref as AnshinAlertsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lat: lat,
        lng: lng,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AnshinAlert>> createElement() {
    return _AnshinAlertsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnshinAlertsProvider &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lat.hashCode);
    hash = _SystemHash.combine(hash, lng.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AnshinAlertsRef on AutoDisposeStreamProviderRef<List<AnshinAlert>> {
  /// The parameter `lat` of this provider.
  double get lat;

  /// The parameter `lng` of this provider.
  double get lng;
}

class _AnshinAlertsProviderElement
    extends AutoDisposeStreamProviderElement<List<AnshinAlert>>
    with AnshinAlertsRef {
  _AnshinAlertsProviderElement(super.provider);

  @override
  double get lat => (origin as AnshinAlertsProvider).lat;
  @override
  double get lng => (origin as AnshinAlertsProvider).lng;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
