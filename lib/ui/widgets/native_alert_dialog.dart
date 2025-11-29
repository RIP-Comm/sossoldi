import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An alert dialog with the native look and feel.
///
/// It uses [Platform] to check whether to return an iOS or an Android dialog.
///
/// The Android variant uses [AlertDialog] while the iOS variant uses [CupertinoAlertDialog].
///
/// Being the actions used in dialogs quite different between the two platforms, the [actions] property maps to the
/// appropriate widget, [TextButton] on Android and [CupertinoDialogAction] on iOS.
class AdaptiveDialog extends StatelessWidget {
  /// [List] of actions, mapped to [TextButton] on Android and to [CupertinoDialogAction] on iOS.
  final List<AdaptiveDialogAction>? actions;

  /// The title of the dialog.
  final Widget? title;

  /// The content of the dialog.
  final Widget? content;

  const AdaptiveDialog({super.key, this.actions, this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? _AndroidDialog(actions: actions, title: title, content: content)
        : _CupertinoDialog(actions: actions, title: title, content: content);
  }
}

/// A convenience class for a generic dialog action.
///
/// Used to map a generic action to the platform specific Widget.
class AdaptiveDialogAction {
  /// The child of the action, usually a [Text].
  final Widget child;

  /// Callback to be executed when the action is pressed.
  final VoidCallback? onPressed;

  /// Only used on iOS. When `true` the action [Text] will be [CupertinoColors.systemRed].
  final bool isDestructiveAction;

  /// Only used on iOS. When `true` the action [Text] will be bold.
  final bool isDefaultAction;

  AdaptiveDialogAction({
    required this.child,
    this.onPressed,
    this.isDestructiveAction = false,
    this.isDefaultAction = false,
  });
}

class _AndroidDialog extends StatelessWidget {
  final List<AdaptiveDialogAction>? actions;
  final Widget? title;
  final Widget? content;

  const _AndroidDialog({this.actions, this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions != null
          ? actions!
                .map(
                  (action) => TextButton(
                    onPressed: action.onPressed,
                    child: action.child,
                  ),
                )
                .toList()
          : [],
    );
  }
}

class _CupertinoDialog extends StatelessWidget {
  final List<AdaptiveDialogAction>? actions;
  final Widget? title;
  final Widget? content;

  const _CupertinoDialog({this.actions, this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions != null
          ? actions!
                .map(
                  (action) => CupertinoDialogAction(
                    isDestructiveAction: action.isDestructiveAction,
                    isDefaultAction: action.isDefaultAction,
                    onPressed: action.onPressed,
                    child: action.child,
                  ),
                )
                .toList()
          : [],
    );
  }
}
