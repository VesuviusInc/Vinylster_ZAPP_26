import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import './ui/screens/local_game.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SpotifyService>(
          create: (context) => SpotifyService()..checkAutoConnect(),
        ),
        Provider<LocalTrackRepository>(create: (_) => LocalTrackRepository()),
        ProxyProvider<SpotifyService, CustomTrackRepository>(
          update: (context, spotifyService, _) =>
              CustomTrackRepository(spotifyService),
        ),
        ChangeNotifierProxyProvider3<
          LocalTrackRepository,
          CustomTrackRepository,
          SpotifyService,
          GameSession
        >(
          create: (context) => GameSession(
            localTrackRepository: context.read<LocalTrackRepository>(),
            customTrackRepository: context.read<CustomTrackRepository>(),
            spotifyService: context.read<SpotifyService>(),
          ),
          update:
              (
                context,
                localTrackRepo,
                customTrackRepo,
                spotifyService,
                previous,
              ) =>
                  previous ??
                  GameSession(
                    localTrackRepository: localTrackRepo,
                    customTrackRepository: customTrackRepo,
                    spotifyService: spotifyService,
                  ),
        ),
      ],
      child: const MyApp(),
    ),
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
      body: Center(
        child: ElevatedButton(
          child: const Text('Lokales Spiel'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const localGame(),
              ),
            );
          },
        ),
      ),
    );
  }
}
