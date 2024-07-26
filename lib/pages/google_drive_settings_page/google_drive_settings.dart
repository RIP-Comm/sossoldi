import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/style.dart';
import '../../providers/google_drive_provider.dart';

class GoogleDriveSettings extends ConsumerStatefulWidget {
  const GoogleDriveSettings({super.key});

  @override
  ConsumerState<GoogleDriveSettings> createState() =>
      _GoogleDriveSettingsPageState();
}

class _GoogleDriveSettingsPageState extends ConsumerState<GoogleDriveSettings> {
  @override
  Widget build(BuildContext context) {
    final googleDriveState = ref.watch(googleDriveNotifier);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Google Drive',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      googleDriveState.isGoogleDriveConnected
                          ? "Unlink your Google Drive"
                          : "Link your Google Drive",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 30.0,
                      backgroundColor: blue5,
                      child: IconButton(
                        color: blue5,
                        onPressed: () async {
                          if (googleDriveState.isGoogleDriveConnected) {
                            await ref
                                .read(googleDriveNotifier.notifier)
                                .disconnectDrive();
                          } else {
                            await ref
                                .read(googleDriveNotifier.notifier)
                                .connectDrive(ref);
                          }
                        },
                        icon: Icon(
                          googleDriveState.isGoogleDriveConnected
                              ? Icons.remove_outlined
                              : Icons.add_to_drive_outlined,
                          size: 25.0,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(animation);

                    final exitOffsetAnimation = Tween<Offset>(
                      begin: Offset.zero,
                      end: const Offset(0, 0.5),
                    ).animate(animation);

                    return child.key == const ValueKey('connected')
                        ? SlideTransition(position: offsetAnimation, child: child)
                        : SlideTransition(position: exitOffsetAnimation, child: child);
                  },
                  child: googleDriveState.isGoogleDriveConnected
                      ? Column(
                          key: const ValueKey('connected'),
                          children: [
                            Row(
                              children: [
                                Text("Push your data to Google Drive",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                const Spacer(),
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: blue5,
                                  child: IconButton(
                                    color: blue5,
                                    onPressed: () async {
                                      await ref
                                          .read(googleDriveNotifier.notifier)
                                          .syncToDrive();
                                    },
                                    icon: Icon(
                                      Icons.upload_outlined,
                                      size: 25.0,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text("Pull your data from Google Drive",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                const Spacer(),
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: blue5,
                                  child: IconButton(
                                    color: blue5,
                                    onPressed: () async {
                                      await ref
                                          .read(googleDriveNotifier.notifier)
                                          .syncFromDrive(ref);
                                    },
                                    icon: Icon(
                                      Icons.download_outlined,
                                      size: 25.0,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('disconnected')),
                ),
              ],
            ),
          ),
        ),
        if (googleDriveState.isLoading)
          const ModalBarrier(dismissible: false, color: Colors.black54),
        if (googleDriveState.isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}