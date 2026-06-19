import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import './ui/screens/local_game.dart';
import './ui/screens/settings.dart';
import './ui/screens/game_screen.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'Home',
      path: '/',
      builder: (context, state) => const VinylsterHomePage(),
    ),
    GoRoute(
      name: 'LocalGame',
      path: '/localgame',
      builder: (context, state) => const LocalGame(),
    ),
    GoRoute(
      name: 'Settings',
      path: '/settings',
      builder: (context, state) => const Settings(),
    ),
    GoRoute(
      name: 'GameScreen',
      path: '/gamescreen',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);



Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SpotifyService>(
          create: (context) => SpotifyService()..checkAutoConnect(),
        ),
        Provider<LocalTrackRepository>(
          create: (context) => LocalTrackRepository(),
        ),
        ChangeNotifierProxyProvider<SpotifyService, CustomTrackRepository>(
          create: (context) =>
              CustomTrackRepository(context.read<SpotifyService>()),
          update: (context, spotifyService, _) =>
              CustomTrackRepository(spotifyService),
        ),
        ChangeNotifierProvider<GameSession>(create: (context) => GameSession()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vinylster',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: _router,
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 200),
            ElevatedButton(
              child: const Text('Local Game'),
              onPressed: () {
                context.goNamed('LocalGame');
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Settings'),
              onPressed: () {
                context.goNamed('Settings');
              },
            ),
          ],
        )

      ),
    );
  }
}
