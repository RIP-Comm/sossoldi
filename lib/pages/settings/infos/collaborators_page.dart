import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/style.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/default_card.dart';

// [name, role, url (without scheme)]
var collaborators = const [
  ["Marco Perugini", "Project Manager", "github.com/theperu"],
  ["Michele Vulcano", "Maintainer, Backend Dev", "github.com/mikev-cw"],
  ["Luca Antonelli", "Maintainer", "github.com/lucaantonelli"],
  ["Federico Pozzato", "UX/UI Designer", "federicopozzato.it"],
  ["GBergatto", "Full Stack Dev", "github.com/GBergatto"],
  ["0xBaggi", "Frontend Dev", "github.com/0xbaggi"],
  ["Alessandro Mariani", "Full Stack Dev", "github.com/marianialessandro"],
  ["filippoml", "Full Stack Dev", "github.com/Filippoml"],
  ["sainzrow", "Backend Dev", "github.com/sainzrow"],
  ["Alessandro Guerra", "Full Stack Dev", "github.com/K-w-e"],
  ["napitek", "Full Stack Dev", "github.com/napitek"],
  ["Alessandro Bongiovanni", "Flutter Dev", "github.com/bongio94"],
  [
    "Emanuel Passaro",
    "Social Media Manager",
    "linkedin.com/in/emanuelpassaro/",
  ],
  [
    "Carolina Verdiani",
    "Marketing Project Manager",
    "linkedin.com/in/carolina-verdiani/",
  ],
  ["Alessia Schina", "UX/UI Designer", "linkedin.com/in/alessiaschina"],
  ["Federico Bruzzone", "Former Maintainer", "github.com/FedericoBruzzone"],
];

// Cycles through the category colour palette for visual variety.
IconData _platformIcon(String url) {
  if (url.contains('github.com')) return FontAwesomeIcons.github;
  if (url.contains('linkedin.com')) return FontAwesomeIcons.linkedin;
  return FontAwesomeIcons.globe;
}

class CollaboratorsPage extends ConsumerWidget {
  const CollaboratorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Collaborators'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: Sizes.xl, bottom: Sizes.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet the team',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    'sossoldi is built and maintained by a passionate open source community. Every feature, fix and idea comes from people like you.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.xl),

            // ── Contributors list ───────────────────────────────────
            Column(
              spacing: Sizes.sm,
              children: List.generate(collaborators.length, (i) {
                final c = collaborators[i];
                return _ContributorCard(name: c[0], role: c[1], url: c[2]);
              }),
            ),

            const SizedBox(height: Sizes.xxl),

            // ── CTA ────────────────────────────────────────────────
            DefaultCard(
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/RIP-Comm/sossoldi')),
              child: Row(
                spacing: Sizes.md,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: blue5,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(Sizes.md),
                    child: const FaIcon(
                      FontAwesomeIcons.github,
                      color: white,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Want to contribute?',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          'Open an issue, submit a PR or just say hi on GitHub',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributorCard extends StatelessWidget {
  const _ContributorCard({
    required this.name,
    required this.role,
    required this.url,
  });

  final String name;
  final String role;
  final String url;

  @override
  Widget build(BuildContext context) {
    return DefaultCard(
      onTap: () => launchUrl(Uri.parse('https://$url')),
      child: Row(
        spacing: Sizes.md,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          FaIcon(
            _platformIcon(url),
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
