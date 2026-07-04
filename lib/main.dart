import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import 'package:vinylster_zapp_26/l10n/app_localizations.dart';
import 'package:vinylster_zapp_26/logic/settings_controller.dart';
import 'package:vinylster_zapp_26/ui/screens/game_over.dart';
import 'package:vinylster_zapp_26/ui/screens/settings_screen.dart';
import './ui/screens/local_game.dart';
import './ui/screens/game_screen.dart';
import './ui/screens/history_screen.dart';
import './ui/screens/history_player_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vinylster_zapp_26/logic/history_database_helper.dart';
import 'package:vinylster_zapp_26/data/models/game_history.dart';
import 'package:vinylster_zapp_26/data/models/game_history_player.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

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
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      name: 'GameScreen',
      path: '/gamescreen',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      name: 'HistoryScreen',
      path: '/historyscreen',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      name: 'HistoryPlayerScreen',
      path: '/historyplayerscreen',
      builder: (context, state) => const HistoryPlayerScreen(),
    ),
    GoRoute(
      name: "GameOver",
      path: "/gameover",
      builder: (context, state) => const GameOver(),
    ),
  ],
);



Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController();
  await settingsController.loadSettings();
  final appDocDir = await getApplicationDocumentsDirectory();
  HistoryDatabaseHelper his = new HistoryDatabaseHelper();
  var uuid = Uuid();
  String uuid1 = uuid.v4();
  String uuid2 = uuid.v4();


  var g1 = GameHistory(gameID: uuid1, time: DateTime.now().toString(), playerAmount: 6);
  var g2 = GameHistory(gameID: uuid2, time: DateTime.now().toString(), playerAmount: 8);
  var play1 = GameHistoryPlayer(gameID: uuid1, name: 'test1');
  var play2 = GameHistoryPlayer(gameID: uuid1, name: 'test2');
  var play3 = GameHistoryPlayer(gameID: uuid2, name: 'test3');
  var play4 = GameHistoryPlayer(gameID: uuid2, name: 'test4');
  his.insertGameHistory(g1);
  his.insertGameHistory(g2);
  his.insertGameHistoryPlayer(play1);
  his.insertGameHistoryPlayer(play2);
  his.insertGameHistoryPlayer(play3);
  his.insertGameHistoryPlayer(play4);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider<SpotifyService>(
          lazy: false,
          create: (context) => SpotifyService(appDocDir.path)..checkAutoConnect(settingsController.autoConnect),
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
      locale: Locale(context.watch<SettingsController>().selectedLanguageLocale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
    final localizations = AppLocalizations.of(context);
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
              child: Text(localizations?.startGame ?? ''),
              onPressed: () {
                context.goNamed('LocalGame');
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: Text(localizations?.settings ?? ''),
              onPressed: () {
                context.goNamed('Settings');
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: Text('History'),
              onPressed: () {
                context.goNamed('HistoryScreen');
              },
            ),
          ],
        )

      ),
    );
  }
}
