import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/providers/google_drive_provider.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  AppLifecycleManagerState createState() => AppLifecycleManagerState();
}

class AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  late ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _container = ProviderContainer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _container.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _handleAppPaused();
    }
  }

  void _handleAppPaused() async {
    final googleDriveState = _container.read(googleDriveNotifier);
    if (googleDriveState.isGoogleDriveConnected) {
      print('Syncing to Google Drive after logout');
      await googleDriveState.syncToDrive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: widget.child,
    );
  }
}