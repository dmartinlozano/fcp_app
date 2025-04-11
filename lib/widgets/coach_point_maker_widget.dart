import 'package:coachmaker/coachmaker.dart';
import 'package:flutter/material.dart';

class CoachPointMakerWidget extends StatelessWidget {
  final bool showCoachPoint;
  final String initial;
  final Widget child;

  const CoachPointMakerWidget({
    super.key,
    required this.showCoachPoint,
    required this.initial,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return showCoachPoint
      ? CoachPoint(
          initial: initial,
          child: child,
        )
      : Container(child: child);
  }
}
