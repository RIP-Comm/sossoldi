import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../ui/device.dart';

/// Countries covered by Enable Banking, as `[flag, name, ISO code]` — same shape as the `languages` table of the general settings page.
const List<List<String>> kEbCountries = [
  ["🇦🇹", "Austria", "AT"],
  ["🇧🇪", "Belgium", "BE"],
  ["🇧🇬", "Bulgaria", "BG"],
  ["🇭🇷", "Croatia", "HR"],
  ["🇨🇾", "Cyprus", "CY"],
  ["🇨🇿", "Czechia", "CZ"],
  ["🇩🇰", "Denmark", "DK"],
  ["🇪🇪", "Estonia", "EE"],
  ["🇫🇮", "Finland", "FI"],
  ["🇫🇷", "France", "FR"],
  ["🇩🇪", "Germany", "DE"],
  ["🇬🇷", "Greece", "GR"],
  ["🇭🇺", "Hungary", "HU"],
  ["🇮🇸", "Iceland", "IS"],
  ["🇮🇪", "Ireland", "IE"],
  ["🇮🇹", "Italy", "IT"],
  ["🇱🇻", "Latvia", "LV"],
  ["🇱🇮", "Liechtenstein", "LI"],
  ["🇱🇹", "Lithuania", "LT"],
  ["🇱🇺", "Luxembourg", "LU"],
  ["🇲🇹", "Malta", "MT"],
  ["🇳🇱", "Netherlands", "NL"],
  ["🇳🇴", "Norway", "NO"],
  ["🇵🇱", "Poland", "PL"],
  ["🇵🇹", "Portugal", "PT"],
  ["🇷🇴", "Romania", "RO"],
  ["🇸🇰", "Slovakia", "SK"],
  ["🇸🇮", "Slovenia", "SI"],
  ["🇪🇸", "Spain", "ES"],
  ["🇸🇪", "Sweden", "SE"],
];

/// Bottom sheet content: pick the country of the bank to connect.
class CountrySelector extends StatelessWidget {
  const CountrySelector({
    required this.scrollController,
    required this.onSelected,
    this.supportedCountries = const [],
    super.key,
  });

  final List<String> supportedCountries;
  final ScrollController scrollController;
  final void Function(String countryCode) onSelected;

  @override
  Widget build(BuildContext context) {
    final countries = kEbCountries
        .where((country) => supportedCountries.contains(country[2]))
        .toList();
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(title: const Text("Country")),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListView.separated(
                  itemCount: countries.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: grey1),
                  itemBuilder: (context, i) {
                    final country = countries[i];
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(country[2]);
                      },
                      leading: Text(
                        country[0],
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamilyFallback: kEmojiFontFallback,
                        ),
                      ),
                      title: Text(country[1]),
                      trailing: Text(
                        country[2],
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: Sizes.sm),
        ],
      ),
    );
  }
}
