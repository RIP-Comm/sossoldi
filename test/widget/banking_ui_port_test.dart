import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/pages/banking/banking_navigation.dart';
import 'package:sossoldi/pages/banking/connect_bank_page.dart';
import 'package:sossoldi/pages/banking/import_accounts_page.dart';
import 'package:sossoldi/pages/banking/widgets/account_import_tile.dart';
import 'package:sossoldi/pages/banking/widgets/account_icon_color_selector.dart';
import 'package:sossoldi/pages/banking/widgets/country_selector.dart';
import 'package:sossoldi/pages/banking/widgets/connection_card.dart';
import 'package:sossoldi/pages/settings/banking/enable_banking_setup_page.dart';
import 'package:sossoldi/providers/accounts_provider.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sossoldi/services/banking/bank_account_data_source.dart';
import 'package:sossoldi/services/banking/banking_account.dart';
import 'package:sossoldi/services/banking/banking_connection.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/banking_request_context.dart';
import 'package:sossoldi/services/banking/bank_institution.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_authorization_result.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_consent_lifecycle_service.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_service.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_request.dart';
import 'package:sossoldi/ui/theme/app_theme.dart';

final now = DateTime.utc(2032, 4, 12, 10);
final connection = BankConnection(
  id: 7,
  providerId: 'test',
  institutionName: 'Test Bank',
  institutionCountry: 'IT',
  applicationId: 'app',
  status: BankConnectionStatus.awaitingImport,
  pendingRemoteConnectionId: 'pending',
  pendingValidUntil: now.add(const Duration(days: 30)),
);
final remoteAccount = BankingAccount(
  reference: BankingAccountReference(
    providerId: 'test',
    remoteId: 'account',
    identityKeys: ['stable'],
  ),
  name: 'Checking',
  currency: 'EUR',
  iban: 'IT60X0542811101000000123456',
);
final institution = BankInstitution(
  providerId: 'test',
  id: 'bank',
  name: 'Test Bank',
  country: 'IT',
  customerTypes: {BankingCustomerType.personal},
);

class _Settings extends EnableBankingSettings {
  final EnableBankingConfig? config;
  _Settings(this.config);
  @override
  Future<EnableBankingConfig?> build() async => config;
}

class _CapturedSettings extends EnableBankingSettings {
  String? savedPem;
  @override
  Future<EnableBankingConfig?> build() async => null;
  @override
  Future<void> save({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
  }) async {
    savedPem = privateKeyPem;
    state = AsyncData(config);
  }
}

class _Connections extends BankConnections {
  @override
  Future<List<BankConnection>> build() async => [connection];
}

class _Accounts extends Accounts {
  @override
  Future<List<BankAccount>> build() async => [];
}

class _Flow extends ConnectBankFlow {
  List<BankAccountImportSelection>? selected;
  @override
  ConnectBankFlowState build() =>
      ConnectBankFlowState(connection: connection, importable: [remoteAccount]);
  @override
  Future<BankSyncSummary> importAccounts(
    List<BankAccountImportSelection> selections,
  ) async {
    selected = selections;
    return BankSyncSummary([
      const BankSyncResult(
        accountId: 1,
        status: BankSyncStatus.retryableFailure,
      ),
    ]);
  }
}

class _InteractiveFlow extends ConnectBankFlow {
  Map<String, String>? received;
  @override
  ConnectBankFlowState build() => const ConnectBankFlowState();
  @override
  Future<List<String>> requiredSyncHeaders(BankConnection connection) async => [
    'Psu-Ip-Address',
  ];
  @override
  Future<BankSyncSummary> syncConnection(
    BankConnection connection, {
    Map<String, String> psuHeaders = const {},
  }) async {
    received = psuHeaders;
    return BankSyncSummary([]);
  }
}

class _Lifecycle implements BankConsentLifecycleService {
  List<({BankingAccount remote, BankAccount? newAccount})>? activated;
  int? activatedId;
  @override
  Future<List<ResumableBankConnection>> resumeAwaitingImports() async => [
    ResumableBankConnection(
      connection: connection,
      details: BankingConnection(
        reference: const BankingConnectionReference(
          providerId: 'test',
          remoteId: 'pending',
        ),
        institution: institution,
        validUntil: now.add(const Duration(days: 30)),
        status: BankingConnectionStatus.active,
        accounts: [remoteAccount.reference],
      ),
    ),
  ];
  @override
  Future<BankConnection> activateConnection(
    int connectionId,
    List<({BankingAccount remote, BankAccount? newAccount})> selections,
  ) async {
    activatedId = connectionId;
    activated = selections;
    return connection.copy(status: BankConnectionStatus.active);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Data implements BankAccountDataSource {
  @override
  Future<BankingAccount> getAccount(
    BankingAccountReference reference, {
    BankingRequestContext context = const BankingRequestContext(),
  }) async => remoteAccount;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sync implements BankSyncService {
  @override
  Future<BankSyncSummary> syncConnection(
    int connectionId, {
    BankSyncRequest request = const BankSyncRequest(),
  }) async => BankSyncSummary([
    const BankSyncResult(
      accountId: 1,
      status: BankSyncStatus.partial,
      warnings: ['invalid_financial_records'],
    ),
  ]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'bank card asks for required interactive context and cancel does not sync',
    (tester) async {
      final flow = _InteractiveFlow();
      const active = BankConnection(
        id: 7,
        providerId: 'test',
        institutionName: 'Test Bank',
        institutionCountry: 'IT',
        applicationId: 'app',
        status: BankConnectionStatus.active,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountsProvider.overrideWith(_Accounts.new),
            connectBankFlowProvider.overrideWith(() => flow),
            bankConnectionSyncStatusProvider(7).overrideWith(
              (ref) async => BankSyncSummary([
                const BankSyncResult(
                  accountId: 1,
                  status: BankSyncStatus.noChange,
                  warnings: ['no_comparable_booked_balance'],
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ConnectionCard(connection: active),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('balance could not be verified'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Sync Test Bank'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(flow.received, isNull);
      await tester.tap(find.byTooltip('Sync Test Bank'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField), '192.0.2.1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(flow.received, {'Psu-Ip-Address': '192.0.2.1'});
    },
  );

  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  setUpAll(() async {
    final loader = FontLoader('NunitoSans');
    loader.addFont(rootBundle.load('assets/fonts/NunitoSans-Regular.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  test(
    'resumes staged remote accounts and activates with a zero opening balance before sync',
    () async {
      final lifecycle = _Lifecycle();
      final container = ProviderContainer(
        overrides: [
          bankConsentLifecycleServiceProvider.overrideWithValue(lifecycle),
          bankAccountDataSourceProvider.overrideWithValue(_Data()),
          bankSyncServiceProvider.overrideWithValue(_Sync()),
          accountsProvider.overrideWith(_Accounts.new),
          bankConnectionsProvider.overrideWith(_Connections.new),
          bankConnectionSyncStatusProvider(
            7,
          ).overrideWith((ref) async => BankSyncSummary([])),
        ],
      );
      addTearDown(container.dispose);
      final flow = container.read(connectBankFlowProvider.notifier);
      await flow.resumeImport(connectionId: 7);
      expect(
        container.read(connectBankFlowProvider).importable.single.reference,
        remoteAccount.reference,
      );
      final summary = await flow.importAccounts([
        BankAccountImportSelection(
          account: remoteAccount,
          name: 'My account',
          symbol: 'payments',
          color: 1,
        ),
      ]);
      expect(lifecycle.activatedId, 7);
      expect(lifecycle.activated!.single.newAccount!.startingValue, 0);
      expect(lifecycle.activated!.single.newAccount!.name, 'My account');
      expect(summary.status, BankSyncStatus.partial);
      expect(bankSyncMessage(summary), contains('could not be synced'));
      expect(container.read(connectBankFlowProvider).connectionId, isNull);
    },
  );

  testWidgets(
    'pasting a real PEM into the hidden key field remains usable when saving',
    (tester) async {
      final settings = _CapturedSettings();
      final container = ProviderContainer(
        overrides: [enableBankingSettingsProvider.overrideWith(() => settings)],
      );
      addTearDown(container.dispose);
      final material = generateEnableBankingKeyMaterial(1024);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const EnableBankingSetupPage(),
            routes: {
              '/connect-bank': (_) => const Scaffold(body: Text('Bank list')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('I already have credentials'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'synthetic-app');
      await tester.enterText(
        find.byType(TextField).at(1),
        material.privateKeyPem,
      );
      final keyField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(keyField.obscureText, isTrue);
      expect(keyField.controller!.text.contains('\n'), isFalse);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Verify and continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify and continue'));
      await tester.pumpAndSettle();
      expect(settings.savedPem != null, isTrue);
      expect(
        () => EnableBankingAuth().buildJwt(
          appId: 'synthetic-app',
          privateKeyPem: settings.savedPem!,
        ),
        returnsNormally,
      );
      expect(find.text('Credentials verified and saved'), findsOneWidget);
    },
  );

  test('IBAN is masked in the imported account tile', () {
    expect(AccountImportTile.maskIban(remoteAccount.iban), 'IT•• ••3456');
  });

  for (final dark in [false, true]) {
    testWidgets(
      'existing setup, connections and import layouts render in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        Future<void> pump(Widget page) async {
          await tester.pumpWidget(
            ProviderScope(
              key: ValueKey(page.runtimeType),
              overrides: [
                enableBankingSettingsProvider.overrideWith(
                  () => _Settings(
                    page is ConnectBankPage
                        ? const EnableBankingConfig(
                            appId: 'app',
                            supportedCountries: ['IT'],
                          )
                        : null,
                  ),
                ),
                bankConnectionsProvider.overrideWith(_Connections.new),
                bankConnectionSyncStatusProvider(
                  7,
                ).overrideWith((ref) async => BankSyncSummary([])),
                accountsProvider.overrideWith(_Accounts.new),
                connectBankFlowProvider.overrideWith(_Flow.new),
                ebAccountBalanceProvider(
                  'account',
                ).overrideWith((ref) async => 100),
              ],
              child: RepaintBoundary(
                key: key,
                child: MaterialApp(
                  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                  home: page,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        for (final entry in <String, Widget>{
          'setup': const EnableBankingSetupPage(),
          'connections': const ConnectBankPage(),
          'import': const ImportAccountsPage(),
        }.entries) {
          await pump(entry.value);
          final directory = Platform.environment['BANKING_UI_SCREENSHOTS'];
          if (directory != null) {
            await tester.runAsync(() async {
              final boundary =
                  key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '$directory/${entry.key}-${dark ? 'dark' : 'light'}.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
        expect(find.text('IT•• ••3456 · EUR'), findsOneWidget);
        expect(find.text('IMPORT SELECTED'), findsOneWidget);
      },
    );
  }

  testWidgets('country picker shows only application-supported countries', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountrySelector(
            scrollController: controller,
            supportedCountries: const ['IT'],
            onSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Italy'), findsOneWidget);
    expect(find.text('Germany'), findsNothing);
  });

  testWidgets(
    'recovered import opens once and can be resumed after back navigation',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          bankingUiBootstrapProvider.overrideWith((ref) async {}),
          bankConsentLifecycleServiceProvider.overrideWithValue(_Lifecycle()),
          bankAccountDataSourceProvider.overrideWithValue(_Data()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: BankingNavigation(
            child: MaterialApp(
              navigatorKey: bankingNavigatorKey,
              navigatorObservers: [bankingNavigationObserver],
              home: const Scaffold(body: Text('Home')),
              routes: {
                '/connect-bank': (_) =>
                    const Scaffold(body: Text('Connections')),
                '/import-accounts': (_) =>
                    const Scaffold(body: Text('Import recovered')),
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await container.read(connectBankFlowProvider.notifier).resumeImport();
      await tester.pumpAndSettle();
      expect(find.text('Import recovered'), findsOneWidget);
      await container.read(connectBankFlowProvider.notifier).resumeImport();
      await tester.pumpAndSettle();
      bankingNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Connections'), findsOneWidget);
      await container.read(connectBankFlowProvider.notifier).resumeImport();
      await tester.pumpAndSettle();
      expect(find.text('Import recovered'), findsOneWidget);
    },
  );
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0, 3.2]) {
      testWidgets(
        'banking accessibility ${dark ? 'dark' : 'light'} at $scale text scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final boundaryKey = GlobalKey();
          final semantics = tester.ensureSemantics();
          try {
            final pages = <Widget>[
              const EnableBankingSetupPage(),
              const ConnectBankPage(),
              const ImportAccountsPage(),
              const EnableBankingSetupPage(),
            ];
            for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
              final page = pages[pageIndex];
              await tester.pumpWidget(
                ProviderScope(
                  key: ValueKey('${page.runtimeType}-$pageIndex'),
                  overrides: [
                    enableBankingSettingsProvider.overrideWith(
                      () => _Settings(
                        page is ConnectBankPage || pageIndex == 3
                            ? const EnableBankingConfig(
                                appId: 'app',
                                supportedCountries: ['IT'],
                              )
                            : null,
                      ),
                    ),
                    bankConnectionsProvider.overrideWith(_Connections.new),
                    bankConnectionSyncStatusProvider(
                      7,
                    ).overrideWith((ref) async => BankSyncSummary([])),
                    accountsProvider.overrideWith(_Accounts.new),
                    connectBankFlowProvider.overrideWith(_Flow.new),
                    ebAccountBalanceProvider(
                      'account',
                    ).overrideWith((ref) async => 100),
                  ],
                  child: MaterialApp(
                    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scale)),
                      child: child!,
                    ),
                    home: RepaintBoundary(key: boundaryKey, child: page),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '${page.runtimeType} at $scale',
              );
              await expectLater(
                tester,
                meetsGuideline(labeledTapTargetGuideline),
              );
              await expectLater(
                tester,
                meetsGuideline(androidTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
              for (final element in find.byType(Text).evaluate()) {
                final text = element.widget as Text;
                final theme = Theme.of(element);
                final style = DefaultTextStyle.of(
                  element,
                ).style.merge(text.style);
                final foreground = style.color ?? theme.colorScheme.onSurface;
                var background = theme.colorScheme.surface;
                element.visitAncestorElements((ancestor) {
                  if (ancestor.widget is ElevatedButton) {
                    background =
                        (ancestor.widget as ElevatedButton)
                            .style
                            ?.backgroundColor
                            ?.resolve({}) ??
                        theme.elevatedButtonTheme.style?.backgroundColor
                            ?.resolve({}) ??
                        theme.colorScheme.secondary;
                    return false;
                  }
                  return true;
                });
                final luminances = [
                  foreground.computeLuminance(),
                  background.computeLuminance(),
                ]..sort();
                expect(
                  (luminances.last + 0.05) / (luminances.first + 0.05),
                  greaterThanOrEqualTo(4.5),
                  reason: 'Text contrast: ${text.data}',
                );
              }
              final evidence =
                  Platform.environment['BANKING_UI_ACCESSIBILITY_SCREENSHOTS'];
              if (evidence != null) {
                await tester.runAsync(() async {
                  final boundary =
                      boundaryKey.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary;
                  final rendered = await boundary.toImage();
                  final bytes = await rendered.toByteData(
                    format: ui.ImageByteFormat.png,
                  );
                  await File(
                    '$evidence/${page.runtimeType}-$pageIndex-${dark ? 'dark' : 'light'}-$scale.png',
                  ).writeAsBytes(bytes!.buffer.asUint8List());
                  rendered.dispose();
                });
              }
              if (page is ImportAccountsPage) {
                final color = find.byTooltip('Blue account color');
                await Scrollable.ensureVisible(
                  tester.element(color),
                  alignment: 0.5,
                );
                await tester.pumpAndSettle();
                expect(color.hitTestable(), findsOneWidget);
                await tester.tap(color);
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              if (page is EnableBankingSetupPage && pageIndex == 0) {
                final existingPath = find.text('I already have credentials');
                await tester.ensureVisible(existingPath);
                await tester.tap(existingPath);
                await tester.pumpAndSettle();
                final keyToggle = find.byTooltip('Show private key');
                await Scrollable.ensureVisible(
                  tester.element(keyToggle),
                  alignment: 0.5,
                );
                await tester.pumpAndSettle();
                expect(keyToggle.hitTestable(), findsOneWidget);
                await tester.tap(keyToggle);
                await tester.pumpAndSettle();
                expect(find.byTooltip('Hide private key'), findsOneWidget);
                expect(tester.takeException(), isNull);
              }
              final scheme =
                  (dark ? AppTheme.darkTheme : AppTheme.lightTheme).colorScheme;
              final luminances = [
                scheme.onSurface.computeLuminance(),
                scheme.surface.computeLuminance(),
              ]..sort();
              expect(
                (luminances.last + 0.05) / (luminances.first + 0.05),
                greaterThanOrEqualTo(4.5),
              );
            }
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }
  test(
    'banking copy uses plurals and preserves incomplete-balance warnings',
    () {
      expect(bankAccountCount(1), '1 account');
      expect(bankAccountCount(2), '2 accounts');
      expect(
        bankSyncMessage(
          BankSyncSummary([
            const BankSyncResult(
              accountId: 1,
              status: BankSyncStatus.noChange,
              warnings: ['no_comparable_booked_balance'],
            ),
          ]),
        ),
        contains('could not be verified'),
      );
    },
  );

  testWidgets(
    'account appearance controls support keyboard and announce selections',
    (tester) async {
      var selectedIcon = 'payments';
      var selectedColor = 0;
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => AccountIconColorSelector(
                  selectedIcon: selectedIcon,
                  selectedColor: selectedColor,
                  onIconChanged: (value) =>
                      setState(() => selectedIcon = value),
                  onColorChanged: (value) =>
                      setState(() => selectedColor = value),
                ),
              ),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byTooltip('Cash icon'), findsOneWidget);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(selectedIcon, 'credit_card');
        await tester.tap(find.byTooltip('Blue account color'));
        await tester.pumpAndSettle();
        expect(selectedColor, 2);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Blue account color').last)
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          ui.Tristate.isTrue,
        );
      } finally {
        semantics.dispose();
      }
    },
  );
}
