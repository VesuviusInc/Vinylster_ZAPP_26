import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';
import 'package:vinylster_zapp_26/logic/settings_controller.dart';

import '../../logic/game_session.dart';

class AudioPlayerControl extends StatefulWidget {
  const AudioPlayerControl({super.key});

  @override
  State createState() => _AudioPlayerControlState();
}

class _AudioPlayerControlState extends State<AudioPlayerControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var _hasBeenReplayed = false;
  String? _currentTrackId;
  bool? _wasConnected;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(seconds: SpotifyService.songPreviewLengthSeconds),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void playSong() {
    // when reversing/resetting the animation, nothing should happen
    if (_animationController.status == AnimationStatus.reverse) {
      return;
    }

    // when animation is done, nothing should happen, to replay the song => replaySong()
    if (_animationController.value == 1.0) {
      return;
    }

    if (_animationController.value == 0.0) {
      _animationController.animateTo(1.0);
      context.read<SpotifyService>().playSong(
        context.read<GameSession>().currentTrack,
      );
    } else {
      context.read<SpotifyService>().resumeSong();
      _animationController.animateTo(1.0);
    }
  }

  void pauseSong() {
    // when reversing/resetting the animation, nothing should happen
    if (_animationController.status == AnimationStatus.reverse) {
      return;
    }

    // already paused at the positions 0.0 and 1.0
    if (_animationController.value == 0.0 ||
        _animationController.value == 1.0) {
      return;
    }

    _animationController.stop();
    context.read<SpotifyService>().pauseSong();
  }

  void replaySong() {
    // when reversing/resetting the animation, nothing should happen
    if (_animationController.status == AnimationStatus.reverse) {
      return;
    }

    // prevent replay, when song hasn't been played yet
    if (_animationController.value < 0.1) {
      return;
    }
    if (!_hasBeenReplayed) {
      _animationController.duration = Duration(seconds: 3);
      _animationController.reverse().then((_) {
        _animationController.duration = Duration(
          seconds: SpotifyService.songPreviewLengthSeconds,
        );
        _animationController.animateTo(1.0);
        context.read<SpotifyService>().playSong(
          context.read<GameSession>().currentTrack,
        );
      });
      _hasBeenReplayed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotifyService = context.watch<SpotifyService>();
    final gameSession = context.watch<GameSession>();
    final currentTrackIdFromGameSession = gameSession.currentTrack != null
        ? gameSession.currentTrack!.trackId
        : "";
    final isConnected = spotifyService.isConnected;
    final settingsController = context.watch<SettingsController>();
    final screenWidth = MediaQuery.of(context).size.width;

    // in case the connections drops while playing
    if (_wasConnected == true && !isConnected) {
      Future.microtask(() {
        if (_animationController.isAnimating) {
          _animationController.reset();
        }
      });
    }

    _wasConnected = isConnected;
    // stopping current song when, song is changed
    if (_currentTrackId != currentTrackIdFromGameSession) {
      _currentTrackId = currentTrackIdFromGameSession;

      Future.microtask(() {
        _animationController.duration = Duration(seconds: 1, milliseconds: 500);
        _animationController.reverse().then((_) {
          _animationController.duration = Duration(
            seconds: SpotifyService.songPreviewLengthSeconds,
          );
        });
        _hasBeenReplayed = false;
        spotifyService.stopSong();
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.25,
        right: screenWidth * 0.25,
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 20,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.tonal(
                // onPressed = null => button is disabled
                onPressed: isConnected ? () => pauseSong() : null,
                style: FilledButton.styleFrom(
                  backgroundColor: isConnected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey,
                ),
                child: Icon(Icons.pause),
              ),
              FilledButton.tonal(
                // onPressed = null => button is disabled
                onPressed: isConnected ? () => playSong() : null,
                style: FilledButton.styleFrom(
                  backgroundColor: isConnected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey,
                ),
                child: Icon(Icons.play_arrow),
              ),
              FilledButton.tonal(
                // onPressed = null => button is disabled
                onPressed: isConnected ? () => replaySong() : null,
                style: FilledButton.styleFrom(
                  backgroundColor: isConnected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey,
                ),
                child: Icon(Icons.replay),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_animationController),
                child: Image(
                  image: AssetImage(
                    "assets/images/${settingsController.vinylImages[settingsController.selectedVinylImageIndex]}.png",
                  ),
                  width: screenWidth * 0.5 > 500.0 ? 500.0 : screenWidth * 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
