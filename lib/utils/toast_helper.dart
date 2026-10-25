import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../constants/app_constants.dart';

class ToastHelper {
  static void show(
    BuildContext context, {
    required String title,
    Duration? autoCloseDuration,
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      autoCloseDuration: autoCloseDuration ?? ToastConfig.autoCloseDuration,
      style: ToastificationStyle.flat,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      margin: ToastConfig.margin,
    );
  }

  static void success(BuildContext context, String message) {
    show(context, title: message);
  }

  static void info(BuildContext context, String message) {
    show(context, title: message);
  }
}
