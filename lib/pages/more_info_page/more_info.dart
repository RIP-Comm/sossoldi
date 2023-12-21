// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../custom_widgets/default_container.dart';

class MoreInfoPage extends ConsumerStatefulWidget {
  const MoreInfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<MoreInfoPage> createState() => _MoreInfoPageState();
}

var moreInfoOptions = const [
  [
    "App Version:",
    "0.1.0",
    null,
  ],
  [
    "Collaborators",
    "See the team behind this app",
    "/collaborators",
  ],
  [
    "Privacy Policy",
    "Read more",
    "/privacy-policy",
  ],
];

class _MoreInfoPageState extends ConsumerState<MoreInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Info',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ListView.separated(
          itemCount: moreInfoOptions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            List option = moreInfoOptions[i];
            return DefaultContainer(
              onTap: () {
                option[2] != null
                    ? Navigator.of(context).pushNamed(option[2] as String)
                    : print("click");
              },
              child: Row(
                children: [
                  const SizedBox(width: 12.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option[0].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        option[1].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
