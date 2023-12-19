import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../constants/style.dart";

class LabelListTile extends ConsumerWidget {
  const LabelListTile({
    required this.labelController,
    required this.labelProvider,
    Key? key,
  }) : super(key: key);

  final TextEditingController labelController;
  final StateProvider labelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.description,
                size: 24.0,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Label",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: labelController,
              decoration: const InputDecoration(border: InputBorder.none),
              textAlign: TextAlign.end,
              style:
                  Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
              onChanged: (value) =>
                  ref.read(labelProvider.notifier).state = value,
            ),
          ),
        ],
      ),
    );
  }
}
