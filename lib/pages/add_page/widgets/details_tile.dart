import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/style.dart';

class DetailsTile extends ConsumerWidget {
  const DetailsTile(
    this.provider,
    this.title,
    this.icon,
    this.func, {
    Key? key,
    this.value
  }) : super(key: key);

  final AutoDisposeStateProvider provider;
  final String? value;
  final String title;
  final IconData icon;
  final VoidCallback func;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: InkWell(
        onTap: func,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                icon,
                size: 24.0,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value ?? '',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: grey1),
            ],
          ),
        ),
      ),
    );
  }
}
