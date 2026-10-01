import 'package:flutter/widgets.dart';

/// Phosphor icons, Light weight (https://phosphoricons.com), from
/// `assets/fonts/Phosphor-Light.ttf`. Only that one font is bundled instead of
/// the `phosphor_flutter` package, which ships all six weights (~1 MB).
///
/// Only directional icons set `matchTextDirection`, so phones, pencils, etc.
/// are not mirrored in this RTL app.
abstract final class AppIcons {
  static const _f = 'PhosphorLight';

  static const users = IconData(0xe4d6, fontFamily: _f);
  static const user = IconData(0xe4c2, fontFamily: _f);
  static const userPlus = IconData(0xe4d0, fontFamily: _f);
  static const search = IconData(0xe30c, fontFamily: _f);
  static const database = IconData(0xe1de, fontFamily: _f);
  static const edit = IconData(0xe3b4, fontFamily: _f);
  static const archive = IconData(0xe00c, fontFamily: _f);
  static const unarchive = IconData(0xe038, fontFamily: _f);
  static const calendar = IconData(0xe10a, fontFamily: _f);
  static const plus = IconData(0xe3d4, fontFamily: _f);
  static const minus = IconData(0xe32a, fontFamily: _f);
  static const share = IconData(0xe408, fontFamily: _f);
  static const phone = IconData(0xe3b8, fontFamily: _f);
  static const note = IconData(0xe63e, fontFamily: _f);
  static const close = IconData(0xe4f6, fontFamily: _f);
  static const download = IconData(0xe20c, fontFamily: _f);
  static const upload = IconData(0xe4c0, fontFamily: _f);
  static const info = IconData(0xe2ce, fontFamily: _f);
  static const warning = IconData(0xe4e0, fontFamily: _f);
  static const success = IconData(0xe184, fontFamily: _f);
  static const error = IconData(0xe4f8, fontFamily: _f);
  static const wallet = IconData(0xe68a, fontFamily: _f);
  static const receipt = IconData(0xe3ec, fontFamily: _f);
  static const save = IconData(0xe248, fontFamily: _f);
  static const empty = IconData(0xe4aa, fontFamily: _f);

  /// "Back": points left in LTR and right in RTL.
  static const back = IconData(0xe058,
      fontFamily: _f, matchTextDirection: true);

  /// Calendar month navigation: "previous" points to the start side.
  static const previous = IconData(0xe138,
      fontFamily: _f, matchTextDirection: true);
  static const next = IconData(0xe13a,
      fontFamily: _f, matchTextDirection: true);
}

/// MIT notice for the bundled Phosphor font (shown on the licenses page).
const phosphorLicense = '''MIT License

Copyright (c) 2020-2021 Phosphor Icons

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''';
