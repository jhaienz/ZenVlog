import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/profile/badges_provider.dart';

void main() {
  test('XP formula: journeys x 10 + tasks x 5 + distance x 2', () {
    final xp = BadgesProvider.calculateXp(
        journeys: 10, completedTasks: 20, totalDistanceKm: 50);
    expect(xp, 10 * 10 + 20 * 5 + 50 * 2); // 300
  });

  test('Milestone badge at 10 journeys', () {
    final badges = BadgesProvider.earnedMilestoneBadges(12);
    expect(badges.contains('milestone_10'), isTrue);
    expect(badges.contains('milestone_25'), isFalse);
  });

  test('No milestone badges below 10 journeys', () {
    final badges = BadgesProvider.earnedMilestoneBadges(5);
    expect(badges.isEmpty, isTrue);
  });

  test('All milestones at 100 journeys', () {
    expect(BadgesProvider.earnedMilestoneBadges(100).length, 4);
  });
}
