// Draws the app icon in every size the platforms need and writes the PNG files.
// Run after changing the design:   flutter test tool/generate_icons.dart
// Uses Flutter's own renderer, so no image tools are needed.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _background = Color(0xFF993C1D); // terracotta, the app's primary colour
const _foreground = Color(0xFFFFFBF5); // cream
// `flutter test` sets FLUTTER_ROOT; the icon font ships with the Flutter SDK.
final _materialIcons =
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

enum Shape {
  /// Fills the whole square; the system cuts its own shape (iOS, Android adaptive, maskable web).
  fullBleed,

  /// Rounded square with see-through corners (favicon, plain web icons, older Android).
  rounded,
}

class _Spec {
  const _Spec(this.path, this.size, this.shape, {this.iconScale = 0.56});
  final String path;
  final int size;
  final Shape shape;
  final double iconScale; // icon size as a share of the canvas
}

const _ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const _android = 'android/app/src/main/res';

final _specs = <_Spec>[
  const _Spec('web/favicon.png', 64, Shape.rounded, iconScale: 0.62),
  const _Spec('web/icons/Icon-192.png', 192, Shape.rounded),
  const _Spec('web/icons/Icon-512.png', 512, Shape.rounded),
  // Maskable icons may be cut to a circle: keep the icon inside the middle 80%.
  const _Spec(
    'web/icons/Icon-maskable-192.png',
    192,
    Shape.fullBleed,
    iconScale: 0.44,
  ),
  const _Spec(
    'web/icons/Icon-maskable-512.png',
    512,
    Shape.fullBleed,
    iconScale: 0.44,
  ),
  // iPhone home screen: square and opaque, or iOS adds black corners.
  const _Spec('web/icons/apple-touch-icon.png', 180, Shape.fullBleed),
  for (final (dir, size) in [
    ('mdpi', 48),
    ('hdpi', 72),
    ('xhdpi', 96),
    ('xxhdpi', 144),
    ('xxxhdpi', 192),
  ])
    _Spec('$_android/mipmap-$dir/ic_launcher.png', size, Shape.rounded),
  for (final (name, size) in [
    ('20x20@1x', 20), ('20x20@2x', 40), ('20x20@3x', 60),
    ('29x29@1x', 29), ('29x29@2x', 58), ('29x29@3x', 87),
    ('40x40@1x', 40), ('40x40@2x', 80), ('40x40@3x', 120),
    ('60x60@2x', 120), ('60x60@3x', 180),
    ('76x76@1x', 76), ('76x76@2x', 152), ('83.5x83.5@2x', 167),
    (
      '1024x1024@1x',
      1024,
    ), // App Store: no transparency allowed, hence full bleed
  ])
    _Spec('$_ios/Icon-App-$name.png', size, Shape.fullBleed),
];

class _IconArt extends StatelessWidget {
  const _IconArt(this.spec);
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final s = spec.size.toDouble();
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: spec.shape == Shape.rounded
            ? BorderRadius.circular(s * 0.22)
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: s * spec.iconScale,
        color: _foreground,
      ),
    );
  }
}

void main() {
  testWidgets('generate app icons', (tester) async {
    final font = File(_materialIcons).readAsBytesSync();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(font)))).load();

    for (final spec in _specs) {
      final s = spec.size.toDouble();
      tester.view.physicalSize = Size(s, s);
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(key: key, child: _IconArt(spec)),
          ),
        ),
      );
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File(spec.path).writeAsBytesSync(bytes!);
      if (spec.path.startsWith(_ios) || spec.path.endsWith('apple-touch-icon.png')) {
        await tester.runAsync(() => _removeAlpha(spec.path));
      }
    }
    tester.view.reset();
  });
}

/// The App Store rejects icons with a transparency channel, even an unused one.
/// Round-trips through JPEG with macOS's built-in `sips` to drop it.
Future<void> _removeAlpha(String path) async {
  if (!Platform.isMacOS) {
    throw UnsupportedError(
      'Run this on a Mac (uses sips) to make the iOS icons.',
    );
  }
  final jpeg = '${Directory.systemTemp.path}/recipe_app_icon.jpg';
  await Process.run('sips', [
    '-s',
    'format',
    'jpeg',
    '-s',
    'formatOptions',
    '100',
    path,
    '--out',
    jpeg,
  ]);
  await Process.run('sips', ['-s', 'format', 'png', jpeg, '--out', path]);
}
