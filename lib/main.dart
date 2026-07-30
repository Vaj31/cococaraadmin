import 'package:ccpladmin/helpers/extensions/app_localization_delegate.dart';
import 'package:ccpladmin/helpers/services/localizations/language.dart';
import 'package:ccpladmin/helpers/services/navigation_services.dart';
import 'package:ccpladmin/helpers/services/storage/local_storage.dart';
import 'package:ccpladmin/helpers/theme/app_notifier.dart';
import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:ccpladmin/services/auth_service.dart';
import 'package:ccpladmin/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appNotifierProvider = ChangeNotifierProvider<AppNotifier>((ref) => AppNotifier());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  // Check if the user was already logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  AuthService.isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(appNotifierProvider);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeCustomizer.instance.theme,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: "/splash",
      getPages: getPageRoute(),
      builder: (context, child) {
        NavigationService.registerContext(context);
        return Directionality(textDirection: AppTheme.textDirection, child: child ?? Container());
      },
      localizationsDelegates: [
        AppLocalizationsDelegate(context),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: Language.getLocales(),
    );
  }
}
