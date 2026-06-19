import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
            onPressed: () {
              context.goNamed('Home');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Center(
        child: const Text("Settings Screen")
      ),
    );
  }
}