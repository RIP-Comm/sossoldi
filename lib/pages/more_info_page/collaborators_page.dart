// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class CollaboratorsPage extends ConsumerStatefulWidget {
  const CollaboratorsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<CollaboratorsPage> createState() => _CollaboratorsPageState();
}

var collaborators = const [
  [
    "Marco Perugini",
    "Project Manager",
    "github.com/theperu",
  ],
  [
    "Michele Vulcano",
    "Maintainer, Backend Dev",
    "github.com/mikev-cw",
  ],
  [
    "Federico Bruzzone",
    "Maintainer",
    "github.com/FedericoBruzzone",
  ],
  [
    "Luca Antonelli",
    "Maintainer",
    "github.com/lucaantonelli",
  ],
  [
    "Federico Pozzato",
    "UX/UI Designer",
    "federicopozzato.it",
  ],
  [
    "GBergatto",
    "Full Stack Dev",
    "github.com/GBergatto",
  ],
  [
    "0xBaggi",
    "Frontend Dev",
    "github.com/0xbaggi",
  ],
  [
    "Alessandro Mariani",
    "Full Stack Dev",
    "github.com/marianialessandro",
  ],
  [
    "filippoml",
    "Full Stack Dev",
    "github.com/Filippoml",
  ],
  [
    "sainzrow",
    "Backend Dev",
    "github.com/sainzrow",
  ],
  [
    "Alessandro Guerra",
    "Full Stack Dev",
    "github.com/K-w-e",
  ],
  [
    "napitek",
    "Full Stack Dev",
    "github.com/napitek",
  ]
];

class _CollaboratorsPageState extends ConsumerState<CollaboratorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Collaborators'),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: collaborators.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          List option = collaborators[i];
          return InkWell(
            onTap: () {
              Uri url = Uri.parse("https://${option[2]}");
              launchUrl(url);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                  const SizedBox(height: 4),
                  Text(
                    option[1].toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option[2].toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
