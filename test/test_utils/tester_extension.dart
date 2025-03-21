import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

extension $WidgetTester on WidgetTester {
  Future<void> pumpWidgetWithMaterialApp(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    bool wrapWithView = true,
    bool hasProviderScope = true,
  }) {
    return pumpWidget(
      hasProviderScope
          ? MaterialApp(
              home: Material(
                child: ProviderScope(
                  child: widget,
                ),
              ),
            )
          : MaterialApp(
              home: Material(
                child: widget,
              ),
            ),
      duration: duration,
      phase: phase,
      wrapWithView: wrapWithView,
    );
  }
}
