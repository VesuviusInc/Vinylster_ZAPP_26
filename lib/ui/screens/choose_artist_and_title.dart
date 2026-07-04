import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_session.dart';
import '../widgets/custom_game_button.dart';

class ChooseArtistAndTitle extends StatefulWidget {
  const ChooseArtistAndTitle({super.key});

  @override
  State<StatefulWidget> createState() => _ChooseArtistAndTitleState();
}

class _ChooseArtistAndTitleState extends State<ChooseArtistAndTitle> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _artistNameController =
      TextEditingController();
  late final TextEditingController _trackTitleController =
      TextEditingController();
  bool _isChosen = false;

  void setIsChosen(bool b) {
    setState(() {
      _isChosen = b;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameSession = context.watch<GameSession>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isChosen == false) ...[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Artists",
                          hintText: "e.g. Rick Astley",
                          border: OutlineInputBorder(),
                        ),
                        controller: _artistNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter name(s) for the artist(s)";
                          }
                          return null;
                        },
                        readOnly: _isChosen,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Title",
                          hintText: "e.g. Never Gonna Give You Up",
                          border: OutlineInputBorder(),
                        ),
                        controller: _trackTitleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a song title";
                          }
                          return null;
                        },
                        readOnly: _isChosen,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomGameButton(
                              margin: EdgeInsets.all(16),
                              text: "Choose",
                              icon: Icons.check,
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              buttonColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  setIsChosen(true);
                                }
                              },
                            ),
                            CustomGameButton(
                              margin: EdgeInsets.all(16),
                              text: "Cancel",
                              icon: Icons.cancel_outlined,
                              buttonColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              textStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildInfoRow(context, "Correct title:", gameSession.currentTrack!.name),
                                _buildInfoRow(
                                  context,
                                  gameSession.currentTrack!.artists.length > 1 ? "Correct artists:" : "Correct artist:",
                                  gameSession.currentTrack!.getArtistsWithFormat(),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Divider(indent: 40, endIndent: 40),
                                ),
                                _buildInfoRow(context, "Entered title:", _trackTitleController.text),
                                _buildInfoRow(
                                  context,
                                  gameSession.currentTrack!.artists.length > 1 ? "Entered artists:" : "Entered artist:",
                                  _artistNameController.text,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomGameButton(
                                buttonColor: Colors.green.shade300,
                                text: "Accept",
                                icon: Icons.check,
                                onPressed: () {
                                  gameSession.guessStatus = GuessStatus.correct;
                                  gameSession.addTokenToCurrentPlayer();
                                  Navigator.pop(context);
                                },
                              ),
                              CustomGameButton(
                                buttonColor: Colors.red.shade300,
                                text: "Decline",
                                icon: Icons.cancel_outlined,
                                onPressed: () {
                                  gameSession.guessStatus = GuessStatus.wrong;
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _artistNameController.dispose();
    _trackTitleController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(125),
              ),
            ),
            TextSpan(
              text: value.isEmpty ? "-" : value,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
