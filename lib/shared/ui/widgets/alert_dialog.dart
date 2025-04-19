import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

///
/// Builder class to create a customized dialog with some options
/// To simply show a dialog with text, you may also use [showInfoDialog], [showWarningDialog] or [showErrorDialog]
///
class AlertDialogBuilder {
  AlertDialogBuilder({
    required this.text,
    required this.primaryActionText,
    this.dialogType = AlertDialogType.info,
    this.isDismissible = true,
    this.primaryActionFunction,
    this.secondaryActionText,
    this.secondaryActionFunction,
  });

  ///
  /// Main text content of the dialog
  ///
  final String text;

  ///
  /// Text of the primary action button for the dialog
  ///
  final String primaryActionText;

  ///
  /// Severity of the dialog, which changes the UI appearance
  ///
  final AlertDialogType dialogType;

  ///
  /// Whether the dialog can be dismissed tapping outside of it, or not (blocking-style dialog)
  /// Defaults to true
  ///
  final bool isDismissible;

  ///
  /// Function invoked when the primary action button is pressed (optional)
  ///
  final Function()? primaryActionFunction;

  ///
  /// Text for the secondary action button. If null, there won't be a secondary action button in the dialog (optional)
  ///
  final String? secondaryActionText;

  ///
  /// Function invoked when the secondary action button is pressed (optional)
  ///
  final Function()? secondaryActionFunction;

  ///
  /// Shows the alert dialog
  ///
  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _AlertDialog(
          dialogType,
          text,
          primaryActionText,
          primaryActionFunction,
          secondaryActionText,
          secondaryActionFunction,
        );
      },
      barrierDismissible: isDismissible,
    );
  }
}

///
/// Shows an info dialog with given text
///
void showInfoDialog(BuildContext context, String text) => AlertDialogBuilder(
        text: text, dialogType: AlertDialogType.info, primaryActionText: "OK")
    .show(context);

///
/// Shows a success dialog with given text
///
void showSuccessDialog(BuildContext context, String text) => AlertDialogBuilder(
      text: text,
      dialogType: AlertDialogType.success,
      primaryActionText: "OK",
    ).show(context);

///
/// Shows a warning dialog with given text
///
void showWarningDialog(BuildContext context, String text) => AlertDialogBuilder(
      text: text,
      dialogType: AlertDialogType.warning,
      primaryActionText: "OK",
    ).show(context);

///
/// Shows an error dialog with given text
///
void showErrorDialog(BuildContext context, String text) => AlertDialogBuilder(
      text: text,
      dialogType: AlertDialogType.error,
      primaryActionText: "OK",
    ).show(context);

enum AlertDialogType { info, success, warning, error }

class _AlertDialog extends StatelessWidget {
  const _AlertDialog(
    this._dialogType,
    this._text,
    this._primaryActionText,
    this._primaryActionFunction,
    this._secondaryActionText,
    this._secondaryActionFunction,
  );

  final AlertDialogType _dialogType;
  final String _text;
  final String _primaryActionText;
  final Function()? _primaryActionFunction;
  final String? _secondaryActionText;
  final Function()? _secondaryActionFunction;

  @override
  Widget build(BuildContext context) {
    Widget icon = _getIcon();
    List<Widget> actions = _getActions(context);

    return AlertDialog(
      icon: icon,
      content: Text(_text),
      actions: actions,
    );
  }

  Widget _getIcon() {
    switch (_dialogType) {
      case AlertDialogType.info:
        return Icon(Icons.info, color: customColorScheme.primary);
      case AlertDialogType.warning:
        return Icon(Icons.warning, color: customColorScheme.secondary);
      case AlertDialogType.error:
        return Icon(Icons.error, color: customColorScheme.error);
      case AlertDialogType.success:
        return const Icon(Icons.check, color: Colors.green);
    }
  }

  List<Widget> _getActions(BuildContext context) {
    List<Widget> actionWidgets = [];

    // Secondary action comes first, since actions are displayed on screen left to right //
    if (_secondaryActionText != null) {
      actionWidgets.add(TextButton(
        onPressed: () {
          _secondaryActionFunction?.call();
          Navigator.of(context).pop();
        },
        child: Text(
          _secondaryActionText,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ));
    }

    actionWidgets.add(TextButton(
      onPressed: () {
        _primaryActionFunction?.call();
        Navigator.of(context).pop();
      },
      child: Text(
        _primaryActionText,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    ));

    return actionWidgets;
  }
}
