import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/auth/auth_service.dart';
import '../persona/persona.dart';
import '../persona/persona_provider.dart';
import 'ble_transport.dart';
import 'group.dart';
part 'group_provider.g.dart';

@riverpod
class GroupNotifier extends _$GroupNotifier {
  static const _maxMembers = 6;

  @override
  Group? build() {
    ref.onDispose(BleTransport.stopAdvertising);
    return null;
  }

  Future<void> startAsHost() async {
    final myPersona = await ref.read(personaNotifierProvider.future);
    if (myPersona == null) return;

    final myId = AuthService.userId;
    final me =
        MemberPersona(userId: myId, displayName: 'You', persona: myPersona);
    state = Group(
      hostId: myId,
      members: [me],
      mergedPersona: Group.computeMergedPersona([me]),
      status: GroupStatus.forming,
    );
    await BleTransport.startAdvertising(myId);
  }

  void approveMember(MemberPersona newMember) {
    final current = state;
    if (current == null || current.members.length >= _maxMembers) return;
    state = current.copyWith(members: [...current.members, newMember]);
  }

  /// Dev-only: fabricates a member so merge/harmony/itinerary are
  /// testable on a single device (BLE join needs two).
  void addTestMember() {
    final rng = Random();
    final n = (state?.members.length ?? 0) + 1;
    approveMember(MemberPersona(
      userId: 'dev-member-$n',
      displayName: ['Maya', 'Rohan', 'Aiko', 'Ken', 'Lina'][(n - 1) % 5],
      persona: Persona.fromSliders(
        stamina: rng.nextDouble(),
        curiosity: rng.nextDouble(),
        solitudeNeed: rng.nextDouble(),
        natureAffinity: rng.nextDouble(),
        culturalAffinity: rng.nextDouble(),
      ),
    ));
  }

  void activate() {
    state = state?.copyWith(status: GroupStatus.active);
  }

  void dissolve() {
    BleTransport.stopAdvertising();
    state = null;
  }
}
