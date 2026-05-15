import 'package:flutter/material.dart';

class AudioPlayerControl extends StatefulWidget {
  final double screenWidth;
  final int songPreviewLengthSeconds = 30;
  const AudioPlayerControl({super.key, required this.screenWidth});

  @override
  State createState() => _AudioPlayerControlState();
}

class _AudioPlayerControlState extends State<AudioPlayerControl> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(seconds: widget.songPreviewLengthSeconds),
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
    _animationController.animateTo(1.0);
    // TODO: Start playing the song through API calls
  }

  void pauseSong() {
    _animationController.stop();
    // TODO: Pause playing the song through API calls
  }

  void replaySong() {
    _animationController.duration = Duration(seconds: 3);
    _animationController.animateTo(0.0).then((_) {
      _animationController.duration = Duration(seconds: widget.songPreviewLengthSeconds);
      _animationController.animateTo(1.0);
    });
    // TODO: Replay the song through API calls
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.screenWidth * 0.25,
        right: widget.screenWidth * 0.25,
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 20,
            alignment: WrapAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: pauseSong,
                child: Icon(Icons.pause),
              ),
              //Spacer(),
              FloatingActionButton(
                onPressed: playSong,
                child: Icon(Icons.play_arrow),
              ),
              //Spacer(),
              FloatingActionButton(
                onPressed: replaySong,
                child: Icon(Icons.replay),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                child: Image(
                  image: AssetImage("assets/images/vinyl-record.png"),
                  width: widget.screenWidth * 0.5 > 500.0
                      ? 500.0
                      : widget.screenWidth * 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
