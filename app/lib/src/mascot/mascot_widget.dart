import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum OttoMood { neutral, correct, wrong, sleeping }

class MascotWidget extends StatelessWidget {
  const MascotWidget({
    required this.mood,
    this.size = 120,
    super.key,
  });

  final OttoMood mood;
  final double size;

  String get _assetPath {
    switch (mood) {
      case OttoMood.neutral:
        return 'assets/mascot/otto_neutral.svg';
      case OttoMood.correct:
        return 'assets/mascot/otto_correct.svg';
      case OttoMood.wrong:
        return 'assets/mascot/otto_wrong.svg';
      case OttoMood.sleeping:
        return 'assets/mascot/otto_sleeping.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
    );
  }
}
