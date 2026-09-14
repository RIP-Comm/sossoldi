// dart format width=400

import 'dart:async';

import 'package:app_links/app_links.dart';

import 'bank_authorization_callback.dart';

abstract class UriLinkSource {
  Stream<Uri> get uriStream;

  Future<Uri?> getInitialUri();
}

class AppLinksUriSource implements UriLinkSource {
  final AppLinks _appLinks;

  AppLinksUriSource({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();
}

class BankDeeplinkService {
  final UriLinkSource _source;

  StreamSubscription<Uri>? _subscription;
  bool _initialLinkChecked = false;
  final Set<String> _handled = {};
  final Set<String> _inFlight = {};

  BankDeeplinkService({UriLinkSource? source}) : _source = source ?? AppLinksUriSource();

  static BankAuthorizationCallback? parse(Uri uri) {
    // Preserve the callback route already registered by existing applications.
    final redirect = Uri.parse('sossoldi://eb-callback');
    if (uri.scheme != redirect.scheme || uri.host != redirect.host || uri.path != redirect.path || uri.port != redirect.port || uri.userInfo.isNotEmpty || uri.hasFragment) return null;
    final params = uri.queryParametersAll;
    final states = params['state'];
    final codes = params['code'];
    final errors = params['error'];
    final descriptions = params['error_description'];
    if (states?.length != 1 || states!.single.trim().isEmpty || (descriptions != null && descriptions.length != 1)) return null;
    if (errors != null) {
      if (errors.length != 1 || errors.single.trim().isEmpty || codes != null) return null;
    } else if (codes?.length != 1 || codes!.single.trim().isEmpty) {
      return null;
    }
    return BankAuthorizationCallback(code: codes?.single, state: states.single, error: errors?.single, errorDescription: descriptions?.single);
  }

  Future<void> start(Future<BankCallbackDisposition> Function(BankAuthorizationCallback) onCallback, {Future<void> Function(Object error)? onError}) async {
    _subscription ??= _source.uriStream.listen((uri) => unawaited(_dispatch(uri, onCallback, onError)), onError: (Object error) => unawaited(_notifyError(error, onError)));
    if (_initialLinkChecked) return;
    _initialLinkChecked = true;
    try {
      final initial = await _source.getInitialUri();
      if (initial != null) await _dispatch(initial, onCallback, onError);
    } catch (error) {
      await _notifyError(error, onError);
    }
  }

  Future<void> _dispatch(Uri uri, Future<BankCallbackDisposition> Function(BankAuthorizationCallback) onCallback, Future<void> Function(Object error)? onError) async {
    final key = uri.toString();
    if (_handled.contains(key) || !_inFlight.add(key)) return;
    try {
      final callback = parse(uri);
      if (callback == null) return;
      final disposition = await onCallback(callback);
      if (disposition == BankCallbackDisposition.terminal) _handled.add(key);
    } catch (error) {
      await _notifyError(error, onError);
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<void> _notifyError(Object error, Future<void> Function(Object error)? onError) async {
    if (onError != null) await onError(error);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
