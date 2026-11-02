import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/settings/banking/enable_banking_setup_page.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/ui/theme/app_theme.dart';

class _Settings extends EnableBankingSettings {
  final EnableBankingConfig? config;
  _Settings([this.config]);
  bool fail = false;
  @override
  Future<EnableBankingConfig?> build() async => config;
  @override
  Future<void> save({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
  }) async {
    if (fail) {
      state = AsyncError(
        const BankingException(
          providerId: 'test',
          failure: BankingFailure.unavailable,
        ),
        StackTrace.current,
      );
    } else {
      await const EnableBankingCredentialsStore().saveCredentials(
        appId: appId,
        privateKeyPem: privateKeyPem,
        config: config,
      );
      state = AsyncData(config);
    }
  }
}

class _Generator extends EnableBankingKeyGenerator {
  final EnableBankingKeyMaterial material;
  int calls = 0;
  _Generator(this.material);
  @override
  Future<EnableBankingKeyMaterial> generate({
    int keySize = kEnableBankingKeySize,
  }) async {
    calls++;
    return material;
  }
}

class _Picker extends FilePicker {
  Uint8List? exported;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    exported = bytes;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late EnableBankingKeyMaterial material;
  String? copiedText;
  setUpAll(() {
    material = generateEnableBankingKeyMaterial(1024);
  });
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    copiedText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
    FilePicker.platform = _Picker();
  });
  const store = EnableBankingCredentialsStore();

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> pump(
    WidgetTester tester,
    _Generator generator,
    _Settings settings, {
    String id = 'page',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        key: ValueKey(id),
        overrides: [
          enableBankingSettingsProvider.overrideWith(() => settings),
          enableBankingKeyGeneratorProvider.overrideWithValue(generator),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EnableBankingSetupPage(),
          routes: {
            '/connect-bank': (_) =>
                const Scaffold(body: Text('Choose your bank')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'generated key and certificate survive reopening and cancelled export',
    (tester) async {
      final generator = _Generator(material);
      await pump(tester, generator, _Settings());
      await tap(tester, 'First-time setup');
      await tap(tester, 'Generate key & certificate');
      expect(generator.calls, 1);
      final first = await store.readSetupDraft();
      expect(first!.privateKeyPem, material.privateKeyPem);
      expect(first.certificatePem, material.certificatePem);
      expect(find.text('Copy public certificate'), findsNothing);
      expect(find.text('Export public certificate'), findsNothing);
      expect(find.text('Previous step'), findsNothing);
      await tap(tester, 'Continue to registration');
      expect(find.text('Copy public certificate'), findsOneWidget);
      expect(find.text('Export public certificate'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Open Enable Banking')).dy,
        lessThan(tester.getTopLeft(find.text('Copy public certificate')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Copy public certificate')).dy,
        lessThan(tester.getTopLeft(find.text('Copy return address')).dy),
      );
      await tap(tester, 'Copy return address');
      expect(copiedText, first.redirectUri);
      await tap(tester, 'Copy public certificate');
      final copied = copiedText!;
      expect(copied, material.certificatePem);
      expect(copied, isNot(contains('PRIVATE KEY')));
      final picker = _Picker();
      final previous = FilePicker.platform;
      FilePicker.platform = picker;
      addTearDown(() => FilePicker.platform = previous);
      await tap(tester, 'Export public certificate');
      expect(String.fromCharCodes(picker.exported!), material.certificatePem);
      expect(
        String.fromCharCodes(picker.exported!),
        isNot(contains('PRIVATE KEY')),
      );
      expect(find.textContaining('You can export it again'), findsOneWidget);
      await pump(tester, generator, _Settings(), id: 'reopened');
      expect(find.text('Register your application'), findsOneWidget);
      expect(generator.calls, 1);
      expect(
        (await store.readSetupDraft())!.privateKeyPem,
        first.privateKeyPem,
      );
      await tap(tester, 'I have my Application ID');
      expect(find.text('Advanced options'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('Previous step'), findsNothing);
      await tester.enterText(find.byType(TextField), 'saved-progress');
      await tester.pumpAndSettle();
      await pump(tester, generator, _Settings(), id: 'reopened-again');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'saved-progress',
      );
      expect(find.byTooltip('Show private key'), findsNothing);
      expect(generator.calls, 1);
    },
  );

  testWidgets(
    'verification errors keep draft and retry goes directly to bank selection',
    (tester) async {
      final settings = _Settings()..fail = true;
      final generator = _Generator(material);
      await pump(tester, generator, settings);
      await tap(tester, 'I already have credentials');
      await tap(tester, 'Verify and continue');
      expect(
        find.text('Enter your Enable Banking application ID'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).first, 'synthetic-app');
      await tester.enterText(
        find.byType(TextField).last,
        material.privateKeyPem,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tap(tester, 'Verify and continue');
      expect(
        find.text('The bank is temporarily unavailable. Try again.'),
        findsOneWidget,
      );
      expect((await store.readSetupDraft())!.appId, 'synthetic-app');
      expect(await store.readCredentials(), isNull);
      settings.fail = false;
      await tap(tester, 'Verify and continue');
      expect(find.text('Choose your bank'), findsOneWidget);
      expect(await store.readSetupDraft(), isNull);
      expect((await store.readCredentials())!.config.appId, 'synthetic-app');
    },
  );

  testWidgets(
    'configured application ID can be copied without changing credentials',
    (tester) async {
      const config = EnableBankingConfig(appId: 'configured-app');
      await store.saveCredentials(
        appId: config.appId,
        privateKeyPem: material.privateKeyPem,
        config: config,
      );
      await pump(tester, _Generator(material), _Settings(config));
      await tap(tester, 'Copy Application ID');
      expect(copiedText, config.appId);
      expect((await store.readCredentials())!.config.appId, config.appId);
      expect(find.text('Application ID copied'), findsOneWidget);
    },
  );

  testWidgets(
    'failed replacement keeps verified credentials and summary available',
    (tester) async {
      const config = EnableBankingConfig(appId: 'old-app');
      await store.saveCredentials(
        appId: config.appId,
        privateKeyPem: material.privateKeyPem,
        config: config,
      );
      final settings = _Settings(config)..fail = true;
      final generator = _Generator(material);
      await pump(tester, generator, settings);
      expect(find.text('Bank sync is configured'), findsOneWidget);
      await tap(tester, 'Replace credentials');
      await tap(tester, 'I already have credentials');
      await tester.enterText(find.byType(TextField).first, 'new-app');
      await tester.enterText(
        find.byType(TextField).last,
        material.privateKeyPem,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tap(tester, 'Verify and continue');
      expect((await store.readCredentials())!.config.appId, 'old-app');
      await tap(tester, 'Return to configured account');
      expect(find.text('Application ID: old-app'), findsOneWidget);
    },
  );
  testWidgets(
    'corrupt unfinished setup can be restarted without deleting verified credentials',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({
        'eb_setup_draft_v1': 'corrupt',
      });
      await pump(tester, _Generator(material), _Settings());
      expect(
        find.text('Could not load your saved setup. Try again.'),
        findsOneWidget,
      );
      await tap(tester, 'Restart unfinished setup');
      await tap(tester, 'Restart');
      expect(find.text('First-time setup'), findsOneWidget);
      expect(await store.readSetupDraft(), isNull);
    },
  );

  testWidgets(
    'switching to a manual key never offers the previous generated certificate',
    (tester) async {
      final generator = _Generator(material);
      await pump(tester, generator, _Settings());
      await tap(tester, 'First-time setup');
      await tap(tester, 'Generate key & certificate');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tap(tester, 'I already have credentials');
      await tester.enterText(find.byType(TextField).last, 'replacement-key');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tap(tester, 'First-time setup');
      expect((await store.readSetupDraft())!.certificatePem, isNull);
      expect(find.text('Export public certificate'), findsNothing);
      expect(find.text('Continue to registration'), findsNothing);
      expect(find.text('Generate key & certificate'), findsOneWidget);
    },
  );

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0, 3.2]) {
      testWidgets(
        'all wizard steps accessible in ${dark ? "dark" : "light"} at $scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          try {
            for (var step = 0; step < 4; step++) {
              await store.saveSetupDraft(
                EnableBankingSetupDraft(
                  step: step,
                  existingCredentials: step == 3,
                  privateKeyPem: material.privateKeyPem,
                  certificatePem: material.certificatePem,
                ),
              );
              await tester.pumpWidget(
                ProviderScope(
                  key: ValueKey('$dark-$scale-$step'),
                  overrides: [
                    enableBankingSettingsProvider.overrideWith(_Settings.new),
                  ],
                  child: MaterialApp(
                    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scale)),
                      child: child!,
                    ),
                    home: const EnableBankingSetupPage(),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await expectLater(
                tester,
                meetsGuideline(labeledTapTargetGuideline),
              );
              await expectLater(
                tester,
                meetsGuideline(androidTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
              await tester.drag(
                find.byType(SingleChildScrollView).first,
                const Offset(0, -5000),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (step == 3) {
                await tap(tester, 'Verify and continue');
                expect(
                  find.text('Enter your Enable Banking application ID'),
                  findsOneWidget,
                );
                expect(tester.takeException(), isNull);
              }
            }
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }
}
