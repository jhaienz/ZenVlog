import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_service.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/onboarding/onboarding_gate.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/explore/spot.dart';
import '../features/journal/journal_screen.dart';
import '../features/journey/journey_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/tasks/task_screen.dart';

const kSignInRoute = '/signin';
const kHomeRoute = '/';
const kExploreRoute = '/explore';
const kJournalRoute = '/journal';
const kProfileRoute = '/profile';
const kOnboardingRoute = '/onboarding';
const kJourneyActiveRoute = '/journey/active';
const kTaskRoute = '/task';
const kGroupRoute = '/group';
const kCommunityRoute = '/community';

const _tabRoutes = [kHomeRoute, kExploreRoute, kJournalRoute, kProfileRoute];

final router = GoRouter(
  initialLocation: kHomeRoute,
  redirect: (context, state) {
    final signedIn = AuthService.isSignedIn;
    final onSignIn = state.matchedLocation == kSignInRoute;
    final onOnboarding = state.matchedLocation == kOnboardingRoute;
    if (!signedIn && !onSignIn) return kSignInRoute;
    if (signedIn && onSignIn) return kHomeRoute;
    if (signedIn && OnboardingGate.needed && !onOnboarding) return kOnboardingRoute;
    if (signedIn && !OnboardingGate.needed && onOnboarding) return kHomeRoute;
    return null;
  },
  routes: [
    GoRoute(path: kSignInRoute, builder: (_, __) => const SignInScreen()),
    GoRoute(path: kOnboardingRoute, builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: kJourneyActiveRoute,
      builder: (context, state) =>
          JourneyScreen(destinationSpot: state.extra! as Spot),
    ),
    GoRoute(
      path: kTaskRoute,
      builder: (context, state) => TaskScreen(spot: state.extra! as Spot),
    ),
    ShellRoute(
      builder: (context, state, child) => _NavShell(child: child),
      routes: [
        GoRoute(path: kHomeRoute, builder: (_, __) => const HomeScreen()),
        GoRoute(path: kExploreRoute, builder: (_, __) => const ExploreScreen()),
        GoRoute(path: kJournalRoute, builder: (_, __) => const JournalScreen()),
        GoRoute(path: kProfileRoute, builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class _NavShell extends StatelessWidget {
  final Widget child;
  const _NavShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexFor(location),
        onTap: (i) => context.go(_tabRoutes[i]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _indexFor(String location) {
    if (location.startsWith(kExploreRoute)) return 1;
    if (location.startsWith(kJournalRoute)) return 2;
    if (location.startsWith(kProfileRoute)) return 3;
    return 0;
  }
}
