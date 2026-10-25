import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimatedExtensions on Widget {
  Widget animated(bool enabled, {Duration? delay, int? ms}) {
    if (!enabled) return this;
    return animate(
      delay: delay,
    ).fadeIn(duration: Duration(milliseconds: ms ?? 400));
  }
}
