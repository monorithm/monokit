@Tags(['source'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Contracts that are cheaper to enforce against the source than to catch in
/// review. Each one guards an invariant that had already eroded once.
void main() {
  final libDir = Directory('lib');

  List<File> dartFiles() => libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('reduced motion is read only through MonokitMotion', () {
    // `MonokitMotion.reduced` existed but was honoured at 6 sites while ~25
    // others re-implemented the MediaQuery read inline, and most implicit
    // animations ignored the setting entirely. One path, or it rots again.
    const owner = 'monokit_motion.dart';
    final offenders = <String>[];

    for (final file in dartFiles()) {
      if (file.path.endsWith(owner)) continue;
      final source = file.readAsStringSync();
      for (final line in source.split('\n')) {
        if (line.contains('disableAnimations') && line.contains('MediaQuery')) {
          offenders.add('${file.path}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Read reduced motion via MonokitMotion.noAnimation(context), '
          'motion.reduced(context, d) or motion.reducedSpring(context, s) '
          'instead of touching MediaQuery.disableAnimations directly.',
    );
  });

  test('the barrel re-exports widgets.dart, and only widgets.dart', () {
    // monokit.dart is the single canonical import, so it re-exports
    // package:flutter/widgets.dart. Material and Cupertino must never be
    // re-exported — that is what keeps the system Material-free by
    // construction.
    final barrel = File('lib/monokit.dart').readAsStringSync();
    final flutterExports = RegExp(
      r"^\s*export\s+'package:flutter/([\w.]+)'",
      multiLine: true,
    ).allMatches(barrel).map((m) => m.group(1)).toList();
    expect(flutterExports, <String>['widgets.dart']);
  });
}
