import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            context.go('/demo');
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue,
            ),
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Home View',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
