import 'package:flutter/material.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Learning Path', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Your personalized roadmap for this week.'),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  _PathStep(title: 'Arrays & Two Pointers', progress: 0.9, eta: 'Done'),
                  _PathStep(title: 'Binary Search Patterns', progress: 0.6, eta: '2 sessions left'),
                  _PathStep(title: 'Recursion Deep Dive', progress: 0.35, eta: '4 sessions left'),
                  _PathStep(title: 'Dynamic Programming Intro', progress: 0.1, eta: 'Starts next'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({required this.title, required this.progress, required this.eta});

  final String title;
  final double progress;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 8),
            Text(eta, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
