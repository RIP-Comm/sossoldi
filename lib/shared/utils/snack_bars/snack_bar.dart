import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  final snackBar = SnackBar(
    duration: const Duration(seconds: 5),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            message,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onAction != null)
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                onAction.call();
                closeSnackBar(context);
              },
              child: Text(actionLabel ?? 'Close'))
      ],
    ),
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  );

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void closeSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
}
