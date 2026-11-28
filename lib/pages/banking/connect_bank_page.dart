import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/banking_ui_provider.dart';
import '../../ui/device.dart';
import '../../ui/widgets/default_container.dart';
import '../../ui/widgets/rounded_icon.dart';
import 'widgets/aspsp_selector.dart';
import 'widgets/connection_card.dart';
import 'widgets/country_selector.dart';

/// Banking hub: the banks already linked, plus the entry point of the country → bank → consent flow.
class ConnectBankPage extends ConsumerStatefulWidget {
  const ConnectBankPage({super.key});

  @override
  ConsumerState<ConnectBankPage> createState() => _ConnectBankPageState();
}

class _ConnectBankPageState extends ConsumerState<ConnectBankPage> {
  void _openSheet(Widget Function(ScrollController) builder) {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.borderRadius),
          topRight: Radius.circular(Sizes.borderRadius),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.5,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, controller) => builder(controller),
      ),
    );
  }

  void _selectCountry() => _openSheet(
    (controller) => CountrySelector(
      scrollController: controller,
      onSelected: _selectAspsp,
      supportedCountries:
          ref.read(enableBankingSettingsProvider).value?.supportedCountries ??
          const [],
    ),
  );

  void _selectAspsp(String countryCode) => _openSheet(
    (controller) =>
        AspspSelector(scrollController: controller, country: countryCode),
  );

  @override
  Widget build(BuildContext context) {
    final hasCredentials =
        ref.watch(enableBankingSettingsProvider).value != null;
    final connections = ref.watch(bankConnectionsProvider);
    final recoveryIssue = ref.watch(bankRecoveryIssueProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Connect bank'),
        actions: [
          IconButton(
            onPressed: hasCredentials ? _selectCountry : null,
            tooltip: 'Link a bank',
            icon: const Icon(Icons.add_circle),
            splashRadius: 28,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (recoveryIssue != null)
              DefaultContainer(
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    children: [
                      Text(recoveryIssue),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(bankingUiBootstrapProvider),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            if (!hasCredentials)
              DefaultContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Sizes.md,
                  children: [
                    Row(
                      spacing: Sizes.md,
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Expanded(
                          child: Text(
                            "Configure your Enable Banking credentials first",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed('/enable-banking-setup'),
                        child: const Text("CONFIGURE"),
                      ),
                    ),
                  ],
                ),
              )
            else
              connections.when(
                data: (items) => items.isEmpty
                    ? const _NoBankLinked()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) => Container(
                          margin: const EdgeInsets.only(bottom: Sizes.lg),
                          child: ConnectionCard(connection: items[i]),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Column(
                  children: [
                    const Text('Could not load linked banks.'),
                    TextButton(
                      onPressed: () => ref.invalidate(bankConnectionsProvider),
                      child: const Text('Try again'),
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

class _NoBankLinked extends StatelessWidget {
  const _NoBankLinked();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.xl),
      child: Column(
        spacing: Sizes.md,
        children: [
          RoundedIcon(
            icon: Icons.account_balance,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            size: 40,
          ),
          Text(
            "No banks linked yet",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            "Tap + to link your first bank",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
