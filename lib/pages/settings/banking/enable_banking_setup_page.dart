import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/banking_ui_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import 'helpers/enable_banking_certificate_file_picker.dart';
import 'helpers/pem_file_picker.dart';
import 'widgets/confirm_clear_credentials_dialog.dart';
import 'widgets/confirm_regenerate_key_dialog.dart';

const _applicationsUrl = 'https://enablebanking.com/cp/applications';

// Hidden single-line text fields remove pasted newlines, so reconstruct the PEM envelope before signing or saving its unchanged base64 payload.
String _restorePrivateKeyPem(String value) {
  final match = RegExp(
    r'^-----BEGIN (PRIVATE KEY|RSA PRIVATE KEY)-----\s*([A-Za-z0-9+/=\s]+)-----END \1-----$',
  ).firstMatch(value.trim());
  if (match == null) return value;
  final label = match.group(1)!;
  final payload = match.group(2)!.replaceAll(RegExp(r'\s'), '');
  final lines = <String>[];
  for (var offset = 0; offset < payload.length; offset += 64) {
    final end = offset + 64 < payload.length ? offset + 64 : payload.length;
    lines.add(payload.substring(offset, end));
  }
  return '-----BEGIN $label-----\n${lines.join('\n')}\n-----END $label-----';
}

class EnableBankingSetupPage extends ConsumerStatefulWidget {
  const EnableBankingSetupPage({super.key});

  @override
  ConsumerState<EnableBankingSetupPage> createState() =>
      _EnableBankingSetupPageState();
}

class _EnableBankingSetupPageState
    extends ConsumerState<EnableBankingSetupPage> {
  final appId = TextEditingController();
  final pem = TextEditingController();
  final redirect = TextEditingController(text: kEbRelayRedirectUri);
  final scroll = ScrollController();
  late final store = ref.read(enableBankingCredentialsStoreProvider);
  Future<void> writes = Future.value();
  late int setupRevision;
  final appField = GlobalKey();
  final keyField = GlobalKey();
  final redirectField = GlobalKey();
  final appFocus = FocusNode();
  final keyFocus = FocusNode();
  int step = 0;
  bool existing = false;
  bool loading = true;
  bool loadFailed = false;
  EnableBankingConfig? verifiedConfig;
  bool busy = false;
  bool editing = false;
  bool pemVisible = false;
  String? draftKey;
  String? certificate;
  String? error;
  String? appError;
  String? keyError;
  String? redirectError;

  @override
  void initState() {
    super.initState();
    setupRevision = store.beginSetupEditing();
    unawaited(_load());
  }

  @override
  void dispose() {
    appFocus.dispose();
    keyFocus.dispose();
    appId.dispose();
    pem.dispose();
    redirect.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await store.flushSetupWrites();
      if (!mounted) return;
      final config = await ref.read(enableBankingSettingsProvider.future);
      if (config != null) await store.clearVerifiedSetupDraft();
      final draft = await store.readSetupDraft();
      if (!mounted) return;
      setState(() {
        verifiedConfig = config;
        loadFailed = false;
        if (draft != null) {
          step = draft.step;
          existing = draft.existingCredentials;
          appId.text = draft.appId;
          redirect.text = draft.redirectUri;
          draftKey = draft.privateKeyPem;
          certificate = draft.certificatePem;
        } else if (config != null) {
          appId.text = config.appId;
          redirect.text = config.redirectUri;
        }
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          loadFailed = true;
          error = 'Could not load your saved setup. Try again.';
        });
      }
    }
  }

  EnableBankingSetupDraft _snapshot({int? nextStep}) => EnableBankingSetupDraft(
    step: nextStep ?? step,
    existingCredentials: existing,
    appId: appId.text.trim(),
    redirectUri: redirect.text.trim(),
    privateKeyPem: pem.text.trim().isEmpty
        ? draftKey
        : _restorePrivateKeyPem(pem.text),
    certificatePem: pem.text.trim().isEmpty ? certificate : null,
  );

  /// Serialize writes so a slower keystroke write cannot overwrite a later step or regenerated key.
  Future<bool> _persist({int? nextStep}) async {
    final snapshot = _snapshot(nextStep: nextStep);
    final revision = setupRevision;
    final operation = store.saveSetupDraftIfCurrent(snapshot, revision);
    writes = operation.then<void>((_) {}).catchError((Object _) {});
    try {
      return await operation;
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not save your progress securely. Keep this screen open and try again.',
        );
      }
      return false;
    }
  }

  void _privateKeyChanged(String value) {
    certificate = null;
    draftKey = value.trim().isEmpty ? null : _restorePrivateKeyPem(value);
    _changed(value);
  }

  void _changed(String _) {
    setState(() {
      appError = null;
      keyError = null;
      redirectError = null;
    });
    unawaited(_persist());
  }

  Future<void> _go(int target) async {
    if (busy) return;
    setState(() => busy = true);
    final saved = await _persist(nextStep: target);
    if (!mounted) return;
    setState(() {
      busy = false;
      if (saved) {
        step = target;
        error = null;
      }
    });
    if (saved && scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> _generate() async {
    if (busy) return;
    if (draftKey != null || pem.text.trim().isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmRegenerateKeyDialog(
          onPressed: () => Navigator.pop(context, true),
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final material = await ref
          .read(enableBankingKeyGeneratorProvider)
          .generate();
      if (!mounted) return;
      final previousKey = draftKey;
      final previousCertificate = certificate;
      final previousPem = pem.text;
      draftKey = material.privateKeyPem;
      certificate = material.certificatePem;
      pem.clear();
      final saved = await _persist();
      if (!mounted) return;
      setState(() {
        if (!saved) {
          draftKey = previousKey;
          certificate = previousCertificate;
          pem.text = previousPem;
        }
        busy = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          busy = false;
          error =
              'Could not generate your key. Your previous setup was kept. Try again.';
        });
      }
    }
  }

  Future<void> _export() async {
    if (certificate == null || busy) return;
    setState(() => busy = true);
    final path = await EnableBankingCertificateFilePicker.saveCertificateFile(
      certificate!,
      context,
    );
    if (!mounted) return;
    setState(() {
      busy = false;
      if (path == null) {
        error =
            'Your certificate is still saved here. You can export it again.';
      } else {
        error = null;
      }
    });
  }

  Future<void> _copy(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) showSnackBar(context, message: message);
  }

  Future<void> _import() async {
    if (busy) return;
    try {
      final file = await PemFilePicker.pickPemFile(context);
      if (file == null) return;
      final contents = await file.readAsString();
      if (!mounted) return;
      pem.text = contents.trim();
      _privateKeyChanged(pem.text);
    } catch (_) {
      if (mounted) {
        setState(
          () => keyError =
              'Could not read this private key. Choose a readable PEM file.',
        );
      }
    }
  }

  Future<void> _portal() async {
    if (!await _persist() || !mounted) return;
    try {
      final opened = await launchUrl(
        Uri.parse(_applicationsUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        setState(
          () => error =
              'Could not open Enable Banking. Try again. Your progress is saved.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not open Enable Banking. Try again. Your progress is saved.',
        );
      }
    }
  }

  Future<void> _verify() async {
    if (busy) return;
    setState(() {
      error = null;
      appError = null;
      keyError = null;
      redirectError = null;
    });
    if (appId.text.trim().isEmpty) {
      setState(() => appError = 'Enter your Enable Banking application ID');
      _focusError(appField, appFocus);
      return;
    }
    String? key = pem.text.trim().isEmpty
        ? draftKey
        : _restorePrivateKeyPem(pem.text);
    if (!mounted) return;
    if (key == null || key.isEmpty) {
      setState(
        () => keyError =
            'Enter or import the private key matching your application',
      );
      _focusError(keyField, existing ? keyFocus : null);
      return;
    }
    try {
      validateEnableBankingRedirect(redirect.text.trim());
    } catch (_) {
      setState(
        () => redirectError =
            'Choose the return address registered for this application',
      );
      _focusError(redirectField, null);
      return;
    }
    try {
      ref
          .read(enableBankingAuthProvider)
          .buildJwt(appId: appId.text.trim(), privateKeyPem: key);
    } catch (_) {
      setState(
        () => keyError =
            'This private key could not be read. Import the matching PEM file or check the pasted key.',
      );
      _focusError(keyField, existing ? keyFocus : null);
      return;
    }
    setState(() => busy = true);
    if (!await _persist() || !mounted) {
      if (mounted) setState(() => busy = false);
      return;
    }
    final container = ProviderScope.containerOf(context, listen: false);
    final settings = ref.read(enableBankingSettingsProvider.notifier);
    final attemptRevision = setupRevision;
    try {
      await settings.save(
        appId: appId.text.trim(),
        privateKeyPem: key,
        config: EnableBankingConfig(
          appId: appId.text.trim(),
          redirectUri: redirect.text.trim(),
        ),
      );
      final failure = container.read(enableBankingSettingsProvider).error;
      if (failure != null) {
        if (mounted) setState(() => error = bankingErrorMessage(failure));
        return;
      }
      if (store.setupRevision != attemptRevision ||
          container.read(enableBankingSettingsProvider).value == null) {
        return;
      }
      await writes;
      try {
        await store.clearVerifiedSetupDraft();
      } catch (_) {
        if (mounted) {
          setState(
            () => error =
                'Credentials were verified. Could not remove the setup draft; retry from settings.',
          );
        }
        return;
      }
      if (!mounted || store.setupRevision != attemptRevision) return;
      setState(() {
        verifiedConfig = container.read(enableBankingSettingsProvider).value;
        editing = false;
        draftKey = null;
        certificate = null;
        pem.clear();
      });
      showSnackBar(context, message: 'Credentials verified and saved');
      await Navigator.of(context).pushNamed('/connect-bank');
    } catch (failure) {
      if (mounted) setState(() => error = bankingErrorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _edit() async {
    EnableBankingSetupDraft? draft;
    try {
      draft = await store.readSetupDraft();
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not open the saved replacement. Try again.',
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      editing = true;
      if (draft == null) {
        step = 0;
        existing = false;
        draftKey = null;
        certificate = null;
        appId.clear();
        redirect.text = kEbRelayRedirectUri;
      }
    });
  }

  Future<void> _restartDraft() async {
    final restart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart unfinished setup?'),
        content: const Text(
          'This removes the unfinished key and certificate. Your verified credentials and imported transactions are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (restart != true || !mounted) return;
    setState(() => busy = true);
    try {
      await writes;
      await store.clearDraftPrivateKey();
      if (!mounted) return;
      setupRevision = store.beginSetupEditing();
      setState(() {
        step = 0;
        existing = false;
        draftKey = null;
        certificate = null;
        appId.clear();
        pem.clear();
        redirect.text = kEbRelayRedirectUri;
        error = null;
      });
      ref.invalidate(enableBankingSettingsProvider);
      await _load();
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not reset the unfinished setup. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _clear() async {
    if (busy) return;
    setState(() => busy = true);
    await writes;
    await ref.read(enableBankingSettingsProvider.notifier).clear();
    if (!mounted) return;
    if (ref.read(enableBankingSettingsProvider).hasError) {
      setState(() {
        busy = false;
        error = 'Could not clear your credentials. Try again.';
      });
      return;
    }
    setupRevision = store.beginSetupEditing();
    setState(() {
      busy = false;
      loadFailed = false;
      editing = false;
      verifiedConfig = null;
      step = 0;
      existing = false;
      draftKey = null;
      certificate = null;
      appId.clear();
      pem.clear();
      redirect.text = kEbRelayRedirectUri;
      error = null;
    });
  }

  void _focusError(GlobalKey field, FocusNode? focus) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      focus?.requestFocus();
      final target = field.currentContext;
      if (target != null) {
        unawaited(
          Scrollable.ensureVisible(
            target,
            alignment: 0.1,
            duration: const Duration(milliseconds: 200),
          ),
        );
      }
    });
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (context) => ConfirmClearCredentialsDialog(
        onPressed: () {
          Navigator.pop(context);
          unawaited(_clear());
        },
      ),
    );
  }

  Widget _button(String label, VoidCallback action, {bool primary = false}) {
    final child = Text(label, textAlign: TextAlign.center);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      foregroundColor: primary
          ? null
          : WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface),
    );
    return SizedBox(
      width: double.infinity,
      child: primary
          ? ElevatedButton(
              onPressed: busy ? null : action,
              style: style,
              child: child,
            )
          : OutlinedButton(
              onPressed: busy ? null : action,
              style: style,
              child: child,
            ),
    );
  }

  Widget _notice(String text, {Key? key}) => Semantics(
    key: key,
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    ),
  );

  Widget _input(
    TextEditingController controller,
    String label, {
    String? issue,
    bool secret = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: Sizes.lg,
      vertical: Sizes.md,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        TextField(
          key: controller == appId ? appField : keyField,
          focusNode: controller == appId ? appFocus : keyFocus,
          controller: controller,
          enabled: !busy,
          obscureText: secret && !pemVisible,
          maxLines: secret && pemVisible ? 6 : 1,
          autocorrect: false,
          enableSuggestions: false,
          style: Theme.of(context).textTheme.titleLarge,
          onChanged: secret ? _privateKeyChanged : _changed,
          decoration: InputDecoration(
            hintText: label,
            errorText: issue,
            errorMaxLines: 5,
            suffixIcon: secret
                ? IconButton(
                    tooltip: pemVisible
                        ? 'Hide private key'
                        : 'Show private key',
                    onPressed: () => setState(() => pemVisible = !pemVisible),
                    icon: Icon(
                      pemVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );

  List<Widget> _summary(EnableBankingConfig config) => [
    const Icon(Icons.check_circle_outline, size: 48),
    const Text(
      'Bank sync is configured',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const Text(
      'Your credentials are stored securely on this device. Manage your bank connections below.',
    ),
    Text('Application ID: ${config.appId}'),
    _button(
      'Copy Application ID',
      () => unawaited(_copy(config.appId, 'Application ID copied')),
    ),
    Text(
      config.environment == EnableBankingEnvironment.sandbox
          ? 'Sandbox · verified'
          : 'Production · verified',
    ),
    _button(
      'Linked banks',
      () => Navigator.of(context).pushNamed('/connect-bank'),
      primary: true,
    ),
    _button(
      draftKey == null ? 'Replace credentials' : 'Resume replacement',
      () => unawaited(_edit()),
    ),
    _button('Clear credentials', _confirmClear),
  ];

  Widget _heading(String text) =>
      Text(text, style: Theme.of(context).textTheme.headlineMedium);

  Widget _description(String text) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      for (final child in children)
        Padding(
          padding: const EdgeInsets.only(top: Sizes.md),
          child: child,
        ),
    ],
  );

  List<Widget> _stepContents() => switch (step) {
    0 => [
      _heading('Connect your bank with Enable Banking'),
      _description(
        'You will need an Enable Banking application and a browser to register it. Sossoldi guides you through the setup, then lets you choose your bank.',
      ),
      _description(
        'Your private key stays in secure storage on this device. Only the public certificate is exported. You can leave and resume this setup.',
      ),
      _button('First-time setup', () {
        existing = false;
        unawaited(_go(1));
      }, primary: true),
      _button('I already have credentials', () {
        existing = true;
        unawaited(_go(3));
      }),
    ],
    1 => [
      _heading('Prepare your key'),
      _section('Private key & public certificate', [
        _description(
          'Generate a private key and its public certificate. Sossoldi keeps them together so you can resume setup without generating another key.',
        ),
        if (certificate != null)
          _notice('Your key is ready and saved securely.'),
        _button(
          certificate == null
              ? 'Generate key & certificate'
              : 'Generate a replacement key',
          () => unawaited(_generate()),
          primary: certificate == null,
        ),
      ]),
      if (certificate != null)
        _button(
          'Continue to registration',
          () => unawaited(_go(2)),
          primary: true,
        ),
    ],
    2 => [
      _heading('Register your application'),
      _section('1. Open Enable Banking', [
        _description('Open Enable Banking and create your application.'),
        _description(
          'Your progress is saved before opening the browser. Return here when registration is complete.',
        ),
        _button('Open Enable Banking', () => unawaited(_portal())),
      ]),
      _section('2. Public certificate', [
        _description(
          'Copy the public certificate into Enable Banking, or export it as a file to upload.',
        ),
        if (certificate != null)
          _button(
            'Copy public certificate',
            () => unawaited(_copy(certificate!, 'Public certificate copied')),
          ),
        if (certificate != null)
          _button('Export public certificate', () => unawaited(_export())),
      ]),
      _section('3. Return address', [
        _description('Register this return address in Enable Banking.'),
        SelectableText(
          redirect.text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        _button(
          'Copy return address',
          () => unawaited(_copy(redirect.text, 'Return address copied')),
        ),
      ]),
      _section('4. Application ID', [
        _description(
          'Copy the Application ID from Enable Banking and return to Sossoldi.',
        ),
      ]),
      _button(
        'I have my Application ID',
        () => unawaited(_go(3)),
        primary: true,
      ),
    ],
    _ => [
      _heading('Verify your credentials'),
      _description(
        existing
            ? 'Enter the Application ID and matching private key from your existing application.'
            : 'Enter the Application ID from Enable Banking. Your generated key is already saved.',
      ),
      _input(appId, 'Application ID', issue: appError),
      if (existing) ...[
        _input(pem, 'Private key (PEM)', issue: keyError, secret: true),
        if (draftKey != null && pem.text.isEmpty)
          const Text(
            'A private key is already saved for this setup. Leave this field empty to use it.',
          ),
        _button('Import private key from file', () => unawaited(_import())),
      ] else if (keyError != null)
        _notice(keyError!, key: keyField),
      if (existing)
        _section('Registered return address', [
          _description(
            'Choose the exact address registered in Enable Banking. The environment is detected when your credentials are verified.',
          ),
          DropdownButtonFormField<String>(
            key: redirectField,
            initialValue:
                {kEbRedirectUri, kEbRelayRedirectUri}.contains(redirect.text)
                ? redirect.text
                : kEbRelayRedirectUri,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Registered return address',
              errorText: redirectError,
              errorMaxLines: 5,
            ),
            items: const [
              DropdownMenuItem(
                value: kEbRelayRedirectUri,
                child: Text('HTTPS return page'),
              ),
              DropdownMenuItem(
                value: kEbRedirectUri,
                child: Text('Direct app link'),
              ),
            ],
            onChanged: busy
                ? null
                : (value) {
                    redirect.text = value!;
                    _changed(value);
                  },
          ),
        ]),
      if (!existing && redirectError != null)
        _notice(redirectError!, key: redirectField),
      _description(
        'Verification needs an internet connection. If it fails, your progress and any previously verified credentials are kept.',
      ),
      _button('Verify and continue', () => unawaited(_verify()), primary: true),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(enableBankingSettingsProvider);
    final config = settings.value ?? verifiedConfig;
    final summary = config != null && !editing;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank sync'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: busy
              ? null
              : () {
                  if (!summary && step > 0) {
                    unawaited(_go(step == 3 && existing ? 0 : step - 1));
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(Sizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!summary) ...[
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        'Step ${step + 1} of 4 · ${const ['Preparation', 'Key', 'Registration', 'Verification'][step]}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (step + 1) / 4,
                      semanticsLabel: 'Setup progress',
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (busy) ...[
                    const LinearProgressIndicator(
                      semanticsLabel: 'Please wait',
                    ),
                    _notice(
                      step == 1
                          ? 'Generating and saving your key. This may take a minute.'
                          : 'Please wait…',
                    ),
                  ],
                  if (error != null) _notice(error!),
                  if (loadFailed)
                    _button('Try loading again', () {
                      ref.invalidate(enableBankingSettingsProvider);
                      unawaited(_load());
                    }),
                  if (loadFailed) _button('Clear credentials', _confirmClear),
                  if (loadFailed)
                    _button(
                      'Restart unfinished setup',
                      () => unawaited(_restartDraft()),
                    ),
                  for (final child
                      in loadFailed
                          ? <Widget>[]
                          : summary
                          ? _summary(config)
                          : _stepContents())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: child,
                    ),
                  if (editing)
                    _button(
                      'Return to configured account',
                      () => setState(() => editing = false),
                    ),
                ],
              ),
            ),
    );
  }
}
