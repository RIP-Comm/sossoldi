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
    "github.com/federicopozzato",
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
  ]
];


class _CollaboratorsPageState extends ConsumerState<CollaboratorsPage> {
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
          'Collaborators',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child:
          Padding(padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.separated(
                  itemCount: collaborators.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, i) {
                    List option = collaborators[i];
                    return InkWell(
                      onTap: () {
                        Uri url = Uri.parse("https://${option[2]}");
                        launchUrl(url);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option[0].toString(),
                              style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.primary),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option[1].toString(),
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primary),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option[2].toString(),
                              style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.primary),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ) 
      ),
    );
  }
}
