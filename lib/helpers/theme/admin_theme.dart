import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:flutter/material.dart';

enum LeftBarThemeType { light, dark }

enum ContentThemeType { light, dark }

enum RightBarThemeType { light, dark }

enum ContentThemeColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  light,
  dark;

  Color get color {
    return (AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]
            ?['color']) ??
        Colors.black;
  }

  Color get onColor {
    return (AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]
            ?['onColor']) ??
        Colors.white;
  }
}

class LeftBarTheme {
  final Color background, onBackground;
  final Color labelColor;
  final Color activeItemColor, activeItemBackground;

  LeftBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff1e293b),
    this.labelColor = const Color(0xff64748b),
    this.activeItemColor = const Color(0xff059840),
    this.activeItemBackground = const Color(0xffF8FFF9),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final LeftBarTheme lightLeftBarTheme = LeftBarTheme();

  static final LeftBarTheme darkLeftBarTheme = LeftBarTheme(
      background: const Color(0xff0f172a),
      onBackground: const Color(0xffe2e8f0),
      labelColor: const Color(0xff94a3b8),
      activeItemBackground: const Color(0xff1e3a8a),
      activeItemColor: const Color(0xff60a5fa));

  static LeftBarTheme getThemeFromType(LeftBarThemeType leftBarThemeType) {
    switch (leftBarThemeType) {
      case LeftBarThemeType.light:
        return lightLeftBarTheme;
      case LeftBarThemeType.dark:
        return darkLeftBarTheme;
    }
  }
}

class TopBarTheme {
  final Color background;
  final Color onBackground;

  TopBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff313a46),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final TopBarTheme lightTopBarTheme = TopBarTheme();

  static final TopBarTheme darkTopBarTheme = TopBarTheme(
      background: Color(0xff2c3036), onBackground: Color(0xffdcdcdc));
}

class RightBarTheme {
  final Color disabled, onDisabled;
  final Color activeSwitchBorderColor, inactiveSwitchBorderColor;

  RightBarTheme({
    this.disabled = const Color(0xffffffff),
    this.activeSwitchBorderColor = const Color(0xff3a86ff),
    // this.activeSwitchBorderColor = const Color(0xff64523c),

    // this.activeSwitchBorderColor = const Color(0xff727cf5),
    this.inactiveSwitchBorderColor = const Color(0xffdee2e6),
    this.onDisabled = const Color(0xff313a46),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final RightBarTheme lightRightBarTheme = RightBarTheme(
      disabled: Color(0xffffffff),
      onDisabled: Color(0xffdee2e6),
      activeSwitchBorderColor: Color(0x773a86ff),
      // activeSwitchBorderColor: Color(0xe364523c),
      inactiveSwitchBorderColor: Color(0xffdee2e6));

  static final RightBarTheme darkRightBarTheme = RightBarTheme(
      disabled: Color(0xff444d57),
      activeSwitchBorderColor: Color(0xff3a86ff),
      // activeSwitchBorderColor: Color(0xe364523c),
      inactiveSwitchBorderColor: Color(0xffdee2e6),
      onDisabled: Color(0xff515a65));
}

class ContentTheme {
  final Color background, onBackground;

  final Color primary, onPrimary;
  final Color secondary, onSecondary;
  final Color success, onSuccess;
  final Color danger, onDanger;
  final Color warning, onWarning;
  final Color info, onInfo;
  final Color light, onLight;
  final Color dark, onDark;

  final Color cardBackground, cardShadow, cardBorder, cardText, cardTextMuted;

  final Color title;

  final Color disabled, onDisabled;

  Map<ContentThemeColor, Map<String, Color>> get getMappedIntoThemeColor {
    var c = AdminTheme.theme.contentTheme;
    return {
      ContentThemeColor.primary: {'color': c.primary, 'onColor': c.onPrimary},
      ContentThemeColor.secondary: {
        'color': c.secondary,
        'onColor': c.onSecondary
      },
      ContentThemeColor.success: {'color': c.success, 'onColor': c.onSuccess},
      ContentThemeColor.info: {'color': c.info, 'onColor': c.onInfo},
      ContentThemeColor.warning: {'color': c.warning, 'onColor': c.onWarning},
      ContentThemeColor.danger: {'color': c.danger, 'onColor': c.onDanger},
      ContentThemeColor.light: {'color': c.light, 'onColor': c.onLight},
      ContentThemeColor.dark: {'color': c.dark, 'onColor': c.onDark},
    };
  }

  ContentTheme({
    this.background = const Color(0xfff8fafc),
    this.onBackground = const Color(0xff1e293b),
    this.primary = const Color(0xff059840),
    this.onPrimary = const Color(0xffffffff),
    this.disabled = const Color(0xffffffff),
    this.onDisabled = const Color(0xffffffff),
    this.secondary = const Color(0xffF8FFF9),
    this.onSecondary = const Color(0xff059840),
    this.success = const Color(0xff10b981),
    this.onSuccess = const Color(0xffffffff),
    this.danger = const Color(0xfff43f5e),
    this.onDanger = const Color(0xffffffff),
    this.warning = const Color(0xfff59e0b),
    this.onWarning = const Color(0xff1e293b),
    this.info = const Color(0xff3b82f6),
    this.onInfo = const Color(0xffffffff),
    this.light = const Color(0xfff1f5f9),
    this.onLight = const Color(0xff1e293b),
    this.dark = const Color(0xff0f172a),
    this.onDark = const Color(0xffffffff),
    this.cardBackground = const Color(0xffffffff),
    this.cardShadow = const Color(0xffffffff),
    this.cardBorder = const Color(0xffffffff),
    this.cardText = const Color(0xff64748b),
    this.cardTextMuted = const Color(0xff94a3b8),
    this.title = const Color(0xff475569),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final ContentTheme lightContentTheme = ContentTheme(
    background: const Color(0xfff8fafc),
    onBackground: const Color(0xff1e293b),
    cardBorder: const Color(0xffe2e8f0),
    cardBackground: const Color(0xffffffff),
    cardShadow: const Color(0xffcbd5e1),
    cardText: const Color(0xff64748b),
    title: const Color(0xff475569),
    cardTextMuted: const Color(0xff94a3b8),
  );

  static final ContentTheme darkContentTheme = ContentTheme(
    background: const Color(0xff0f172a),
    onBackground: const Color(0xfff8fafc),
    disabled: const Color(0xff334155),
    onDisabled: const Color(0xff475569),
    cardBorder: const Color(0xff334155),
    cardBackground: const Color(0xff1e293b),
    cardShadow: const Color(0xff020617),
    cardText: const Color(0xff94a3b8),
    title: const Color(0xffcbd5e1),
    cardTextMuted: const Color(0xff64748b),
  );
}

class AdminTheme {
  final LeftBarTheme leftBarTheme;
  final RightBarTheme rightBarTheme;
  final TopBarTheme topBarTheme;
  final ContentTheme contentTheme;

  AdminTheme({
    required this.leftBarTheme,
    required this.topBarTheme,
    required this.rightBarTheme,
    required this.contentTheme,
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static AdminTheme theme = AdminTheme(
      leftBarTheme: LeftBarTheme.lightLeftBarTheme,
      topBarTheme: TopBarTheme.lightTopBarTheme,
      rightBarTheme: RightBarTheme.lightRightBarTheme,
      contentTheme: ContentTheme.lightContentTheme);

  static void setTheme() {
    theme = AdminTheme(
        leftBarTheme: ThemeCustomizer.instance.theme == ThemeMode.dark
            ? LeftBarTheme.darkLeftBarTheme
            : LeftBarTheme.lightLeftBarTheme,
        topBarTheme: ThemeCustomizer.instance.theme == ThemeMode.dark
            ? TopBarTheme.darkTopBarTheme
            : TopBarTheme.lightTopBarTheme,
        rightBarTheme: ThemeCustomizer.instance.theme == ThemeMode.dark
            ? RightBarTheme.darkRightBarTheme
            : RightBarTheme.lightRightBarTheme,
        contentTheme: ThemeCustomizer.instance.theme == ThemeMode.dark
            ? ContentTheme.darkContentTheme
            : ContentTheme.lightContentTheme);
  }
}
