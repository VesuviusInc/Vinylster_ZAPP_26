import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/services/SpotifyService.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");

  runApp(
      ChangeNotifierProvider(
        create: (context) => SpotifyService(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinylster',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const VinylsterHomePage(),
    );
  }
}

class VinylsterHomePage extends StatelessWidget {
  const VinylsterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Vinylster"),
      ),
      body: Column(

      ),
    );
  }
}
