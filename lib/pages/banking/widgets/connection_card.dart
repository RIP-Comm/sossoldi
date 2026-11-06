import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../model/bank_account.dart';
import '../../../model/bank_connection.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/banking_ui_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import '../../../ui/widgets/default_card.dart';
import '../../../ui/widgets/rounded_icon.dart';
import 'confirm_disconnect_dialog.dart';
import 'bank_sync_context_dialog.dart';

/// One linked bank: how many accounts it feeds, until when the consent is valid and the actions available on it.
class ConnectionCard extends ConsumerStatefulWidget {
  const ConnectionCard({required this.connection, super.key});

  final BankConnection connection;

  @override
  ConsumerState<ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends ConsumerState<ConnectionCard> {
  bool _syncing = false;
  bool _disconnecting = false;

  BankConnection get connection => widget.connection;

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    setState(() => _disconnecting = true);
    try {
      await ref.read(connectBankFlowProvider.notifier).disconnect(connection);
      if (!context.mounted) return;
      showSnackBar(context, message: "Bank disconnected");
    } on EnableBankingAuthException catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } finally {
      if (mounted) setState(() => _disconnecting = false);
    }
  }

  Future<void> _reconnect(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(connectBankFlowProvider.notifier).reconnect(connection);
    } on EnableBankingException catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } on EnableBankingAuthException catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: bankingErrorMessage(e));
      }
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    setState(() => _syncing = true);
    try {
      final flow = ref.read(connectBankFlowProvider.notifier);
      final requiredHeaders = await flow.requiredSyncHeaders(connection);
      if (!context.mounted) return;
      Map<String, String> headers = const {};
      if (requiredHeaders.isNotEmpty) {
        final values = await showDialog<Map<String, String>>(
          context: context,
          builder: (_) => BankSyncContextDialog(headers: requiredHeaders),
        );
        if (values == null || !context.mounted) return;
        headers = values;
      }
      final count = await flow.syncConnection(connection, psuHeaders: headers);
      if (!context.mounted) return;
      showSnackBar(context, message: bankSyncMessage(count));
    } on EnableBankingException catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } on EnableBankingAuthException catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, message: bankingErrorMessage(e));
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: bankingErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).value ?? const <BankAccount>[];
    final linked = accounts
        .where((account) => account.ebConnectionId == connection.id)
        .toList();
    final syncStatus = ref.watch(
      bankConnectionSyncStatusProvider(connection.id!),
    );
    final isExpired =
        connection.status == BankConnectionStatus.expired ||
        connection.status == BankConnectionStatus.reauthRequired ||
        (connection.validUntil != null &&
            !connection.validUntil!.isAfter(DateTime.now().toUtc()));

    return DefaultCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sizes.md,
            children: [
              RoundedIcon(
                icon: Icons.account_balance,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connection.institutionName,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    "${bankAccountCount(linked.length)} · consent valid until "
                    "${(connection.pendingValidUntil ?? connection.validUntil)?.formatEDMY() ?? '—'}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Text(
                isExpired
                    ? "RECONNECT"
                    : switch (connection.status) {
                        BankConnectionStatus.awaitingImport =>
                          'Ready to import',
                        BankConnectionStatus.revocationPending =>
                          'Disconnecting',
                        BankConnectionStatus.active => 'Connected',
                        BankConnectionStatus.authorizing => 'Awaiting consent',
                        _ => 'Reconnect required',
                      },
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          syncStatus.when(
            data: (summary) => !bankSyncNeedsAttention(summary)
                ? const SizedBox.shrink()
                : Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                      child: Text(bankSyncMessage(summary)),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) =>
                const Text('Could not load the last sync result. Try again.'),
          ),
          const SizedBox(height: Sizes.md),
          const Divider(height: 1, color: grey2),
          if (connection.pendingRemoteConnectionId != null)
            TextButton(
              onPressed: () => ref
                  .read(connectBankFlowProvider.notifier)
                  .resumeImport(connectionId: connection.id),
              child: const Text("CONTINUE IMPORT"),
            ),
          if (isExpired)
            Padding(
              padding: const EdgeInsets.only(top: Sizes.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _reconnect(context, ref),
                  child: const Text("RECONNECT"),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Last synced: ${_lastSyncLabel(linked)}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              _syncing
                  ? const Padding(
                      padding: EdgeInsets.all(Sizes.sm),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Sync ${connection.institutionName}',
                      icon: const Icon(Icons.refresh),
                      onPressed:
                          isExpired ||
                              connection.status != BankConnectionStatus.active
                          ? null
                          : () => _sync(context, ref),
                    ),
              _disconnecting
                  ? const Padding(
                      padding: EdgeInsets.all(Sizes.sm),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Disconnect ${connection.institutionName}',
                      icon: const Icon(Icons.link_off, color: red),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (dialogContext) => ConfirmDisconnectDialog(
                          connection: connection,
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _disconnect(context, ref);
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  /// Latest successful server-timed sync across the accounts fed by this connection.
  String _lastSyncLabel(List<BankAccount> linked) {
    final syncs = linked.map((account) => account.lastSyncAt).nonNulls.toList()
      ..sort();
    return syncs.isEmpty ? "never" : syncs.last.formatEDMY();
  }
}
