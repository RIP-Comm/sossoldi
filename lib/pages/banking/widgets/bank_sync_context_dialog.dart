import 'dart:io';

import 'package:flutter/material.dart';

/// Collects only the bank-declared context for one interactive request, without persisting its values.
class BankSyncContextDialog extends StatefulWidget {
  final List<String> headers;
  const BankSyncContextDialog({required this.headers, super.key});

  @override
  State<BankSyncContextDialog> createState() => _BankSyncContextDialogState();
}

class _BankSyncContextDialogState extends State<BankSyncContextDialog> {
  final form = GlobalKey<FormState>();
  late final controllers = {
    for (final header in widget.headers) header: TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Additional details required'),
    content: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your bank requires these details for this refresh. They are sent through Enable Banking only when you continue. The values are not saved.',
          ),
          for (final entry in controllers.entries)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(labelText: entry.key),
                autocorrect: false,
                validator: (raw) {
                  final value = raw?.trim() ?? '';
                  if (value.isEmpty || value.contains(RegExp(r'[\r\n]'))) {
                    return 'Enter a value for this request';
                  }
                  if (entry.key.toLowerCase() == 'psu-ip-address' &&
                      InternetAddress.tryParse(value) == null) {
                    return 'Enter a valid IP address';
                  }
                  return null;
                },
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, {
              for (final entry in controllers.entries)
                entry.key: entry.value.text.trim(),
            });
          }
        },
        child: const Text('Continue'),
      ),
    ],
  );
}
