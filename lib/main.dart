import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/customer_list/customer_list_screen.dart';
import 'theme/app_icons.dart';
import 'theme/app_theme.dart';
import 'widgets/app_alert.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['Phosphor Icons'], phosphorLicense);
  });
  runApp(const DaftarMoeinApp());
}

class DaftarMoeinApp extends StatelessWidget {
  const DaftarMoeinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفتر معین شخصی',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AlertHost(child: child ?? const SizedBox()),
      home: const CustomerListScreen(),
    );
  }
}
