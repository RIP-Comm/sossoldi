import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/constants.dart';
import '../../constants/style.dart';
import '../../providers/banking_ui_provider.dart';
import '../../services/banking/banking_account.dart';
import '../../ui/device.dart';
import '../../ui/snack_bars/snack_bar.dart';
import '../../ui/widgets/alert_dialog.dart';
import '../../ui/widgets/default_container.dart';
import 'widgets/account_import_tile.dart';

/// How the user wants one bank account to land in the app.
class _ImportDraft {
  _ImportDraft({required this.account, required this.nameController});

  BankingAccount account;
  final TextEditingController nameController;
  bool selected = true;
  String symbol = accountIconList.keys.first;
  int color = 0;
}

/// Last leg of the connect flow: pick which accounts of the freshly linked bank become app accounts, and how they look.
class ImportAccountsPage extends ConsumerStatefulWidget {
  const ImportAccountsPage({super.key});

  @override
  ConsumerState<ImportAccountsPage> createState() => _ImportAccountsPageState();
}

class _ImportAccountsPageState extends ConsumerState<ImportAccountsPage> {
  final List<_ImportDraft> drafts = [];
  bool importing = false;

  @override
  void initState() {
    super.initState();

    _reconcile(ref.read(connectBankFlowProvider).importable, reset: true);
  }

  void _reconcile(List<BankingAccount> accounts, {required bool reset}) {
    final previous = {
      for (final draft in drafts) draft.account.reference: draft,
    };
    final next = <_ImportDraft>[];
    for (final account in accounts) {
      final retained = reset ? null : previous.remove(account.reference);
      if (retained != null) {
        retained.account = account;
        next.add(retained);
      } else {
        next.add(
          _ImportDraft(
            account: account,
            nameController: TextEditingController(
              text: account.name ?? account.product ?? 'Account',
            ),
          ),
        );
      }
    }
    final removed = reset ? drafts.toList() : previous.values.toList();
    drafts
      ..clear()
      ..addAll(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final draft in removed) {
        draft.nameController.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (final draft in drafts) {
      draft.nameController.dispose();
    }
    super.dispose();
  }

  Future<void> _import() async {
    final selected = drafts.where((draft) => draft.selected).toList();
    if (selected.isEmpty) return;

    setState(() => importing = true);
    try {
      final syncResult = await ref
          .read(connectBankFlowProvider.notifier)
          .importAccounts([
            for (final draft in selected)
              BankAccountImportSelection(
                account: draft.account,
                name: draft.nameController.text.trim().isEmpty
                    ? "Account"
                    : draft.nameController.text.trim(),
                symbol: draft.symbol,
                color: draft.color,
              ),
          ]);
      if (!mounted) return;

      // The snack bar goes through the root messenger: this route is about to be popped, so its own context cannot show anything.
      Navigator.popUntil(context, ModalRoute.withName('/connect-bank'));
      showRootSnackBar(
        message:
            "${bankAccountCount(selected.length)} imported. "
            "${bankSyncMessage(syncResult)}",
      );
    } on ConnectBankFlowException catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.message);
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Could not import the accounts');
    } finally {
      if (mounted) setState(() => importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectBankFlowProvider, (previous, next) {
      final reset =
          previous?.connection?.id != next.connection?.id ||
          previous?.connection?.remoteConnectionId !=
              next.connection?.remoteConnectionId ||
          previous?.connection?.providerId != next.connection?.providerId;
      setState(() => _reconcile(next.importable, reset: reset));
    });
    final connection = ref.watch(connectBankFlowProvider).connection;
    final selectedCount = drafts.where((draft) => draft.selected).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Import accounts'),
      ),
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 5.0,
            offset: const Offset(0, -1.0),
          ),
        ],
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.sm,
            Sizes.xs,
            Sizes.sm,
            Sizes.sm,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [defaultShadow],
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: ElevatedButton(
              onPressed: selectedCount == 0 || importing ? null : _import,
              child: const Text("IMPORT SELECTED"),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            DefaultContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select the accounts to import",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "${connection?.institutionName ?? 'Bank'} · "
                    "${bankAccountCount(drafts.length)}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (drafts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Sizes.xl),
                child: Text(
                  "The bank did not return any accounts. Try connecting again.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            for (final draft in drafts)
              AccountImportTile(
                account: draft.account,
                selected: draft.selected,
                nameController: draft.nameController,
                symbol: draft.symbol,
                color: draft.color,
                onSelectedChanged: (value) =>
                    setState(() => draft.selected = value),
                onIconChanged: (icon) => setState(() => draft.symbol = icon),
                onColorChanged: (color) => setState(() => draft.color = color),
              ),
          ],
        ),
      ),
    );
  }
}
