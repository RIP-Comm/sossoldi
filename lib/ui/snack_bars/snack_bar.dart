import 'package:flutter/material.dart';

import '../device.dart';

/// Messenger of the root [MaterialApp], used by [showRootSnackBar] to give feedback from outside the widget tree.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

SnackBar _buildSnackBar({
  required String message,
  VoidCallback? onAction,
  String? actionLabel,
  VoidCallback? onClose,
}) => SnackBar(
  duration: const Duration(seconds: 5),
  content: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: 8,
    children: [
      Expanded(
        child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      if (onAction != null)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
          ),
          onPressed: () {
            onAction.call();
            onClose?.call();
          },
          child: Text(actionLabel ?? 'Close'),
        ),
    ],
  ),
  behavior: SnackBarBehavior.floating,
  padding: const EdgeInsets.symmetric(vertical: Sizes.md, horizontal: Sizes.lg),
);

void showSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  final snackBar = _buildSnackBar(
    message: message,
    onAction: onAction,
    actionLabel: actionLabel,
    onClose: () => closeSnackBar(context),
  );

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// Shows a snack bar without a [BuildContext], e.g. from an app level listener such as the Enable Banking OAuth callback handler.
void showRootSnackBar({required String message}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(_buildSnackBar(message: message));
}

void closeSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
}
