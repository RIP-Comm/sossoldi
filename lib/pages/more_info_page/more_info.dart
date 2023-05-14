// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/custom_widgets/default_container.dart';
import '../../constants/style.dart';


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
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0XFF7DA1C4),
          ),
          onPressed: () {
            Navigator.pop(context);
            // Return to previous page
          },
        ),
        title: Text(
          'More Info',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ListView.separated(
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
          ],
        ),
      ),
    );
  }
}
