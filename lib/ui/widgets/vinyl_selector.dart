import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/settings_controller.dart';

class VinylSelector extends StatelessWidget {
  const VinylSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: List.generate(settingsController.vinylImages.length, (index) {

        final isSelected = settingsController.selectedVinylImageIndex == index;

        return GestureDetector(
          onTap: () {
              settingsController.setSelectedVinylIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 4.0 : 0.0),
            margin: EdgeInsets.all(isSelected ? 0.0 : 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF1DB954) : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/${settingsController.vinylImages[index]}.png",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
    );
  }

}