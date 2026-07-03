import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../persona/persona.dart';
import '../persona/persona_provider.dart';
import '../../app/router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  double _stamina = 0.5;
  double _curiosity = 0.5;
  double _solitudeNeed = 0.5;
  double _natureAffinity = 0.5;
  double _culturalAffinity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Design your mindful adventure',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _slider('Stamina', _stamina, (v) => setState(() => _stamina = v)),
                    _slider('Curiosity', _curiosity, (v) => setState(() => _curiosity = v)),
                    _slider('Solitude Need', _solitudeNeed, (v) => setState(() => _solitudeNeed = v)),
                    _slider('Nature Affinity', _natureAffinity, (v) => setState(() => _natureAffinity = v)),
                    _slider('Cultural Affinity', _culturalAffinity, (v) => setState(() => _culturalAffinity = v)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  child: const Text('Start Discovery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Slider(value: value, onChanged: onChanged, activeColor: const Color(0xFFD4A853)),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _start() async {
    final persona = Persona.fromSliders(
      stamina: _stamina,
      curiosity: _curiosity,
      solitudeNeed: _solitudeNeed,
      natureAffinity: _natureAffinity,
      culturalAffinity: _culturalAffinity,
    );
    await ref.read(personaNotifierProvider.notifier).save(persona);
    if (mounted) context.go(kExploreRoute);
  }
}
