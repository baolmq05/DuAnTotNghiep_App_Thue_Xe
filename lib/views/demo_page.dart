import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Container(
              height: 200,
              width: 200,
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  "Demo Page",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Container(
              height: 200,
              width: 200,
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Text(
                  "Demo Page",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
