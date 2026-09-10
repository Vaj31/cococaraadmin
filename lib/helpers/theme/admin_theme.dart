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
  final Color surfaceHover;
  final Color indicatorColor;

  LeftBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff6b7280),
    this.labelColor = const Color(0xff9ca3af),
    this.activeItemColor = const Color(0xff22783a),
    this.activeItemBackground = const Color(0xffeaf7ee),
    this.surfaceHover = const Color(0xffd5f0dc),
    this.indicatorColor = const Color(0xff30ae52),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final LeftBarTheme lightLeftBarTheme = LeftBarTheme();

  static final LeftBarTheme darkLeftBarTheme = LeftBarTheme(
      background: const Color(0xff121212),
      onBackground: const Color(0xff94a3b8),
      labelColor: const Color(0xff6b7280),
      activeItemBackground: const Color(0xff132b1b),
      activeItemColor: const Color(0xff35c75d),
      surfaceHover: const Color(0xff1a3b25),
      indicatorColor: const Color(0xff35c75d));

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
  final Color borderColor;

  TopBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff111827),
    this.borderColor = const Color(0xffb7e4c4),
  });

  //--------------------------------------  Top Bar Theme ----------------------------------------//

  static final TopBarTheme lightTopBarTheme = TopBarTheme();

  static final TopBarTheme darkTopBarTheme = TopBarTheme(
      background: const Color(0xff18181b),
      onBackground: const Color(0xfff3f4f6),
      borderColor: const Color(0xff1f4d2e));
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

  final Color primaryHover, surfaceHover, borderStroke, textAccent;

  ContentTheme({
    this.background = const Color(0xfff8fafc),
    this.onBackground = const Color(0xff1e293b),
    this.primary = const Color(0xff30ae52),
    this.onPrimary = const Color(0xffffffff),
    this.primaryHover = const Color(0xff268c42),
    this.surfaceHover = const Color(0xffd5f0dc),
    this.borderStroke = const Color(0xffb7e4c4),
    this.textAccent = const Color(0xff22783a),
    this.disabled = const Color(0xffffffff),
    this.onDisabled = const Color(0xffffffff),
    this.secondary = const Color(0xffeaf7ee),
    this.onSecondary = const Color(0xff22783a),
    this.success = const Color(0xff30ae52),
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
    this.cardShadow = const Color(0xffcbd5e1),
    this.cardBorder = const Color(0xffb7e4c4),
    this.cardText = const Color(0xff64748b),
    this.cardTextMuted = const Color(0xff9ca3af),
    this.title = const Color(0xff1e293b),
  });

  //--------------------------------------  Content Theme ----------------------------------------//

  static final ContentTheme lightContentTheme = ContentTheme(
    background: const Color(0xfff8fafc),
    onBackground: const Color(0xff1e293b),
    primary: const Color(0xff30ae52),
    onPrimary: const Color(0xffffffff),
    primaryHover: const Color(0xff268c42),
    surfaceHover: const Color(0xffd5f0dc),
    borderStroke: const Color(0xffb7e4c4),
    textAccent: const Color(0xff22783a),
    secondary: const Color(0xffeaf7ee),
    onSecondary: const Color(0xff22783a),
    cardBorder: const Color(0xffb7e4c4),
    cardBackground: const Color(0xffffffff),
    cardShadow: const Color(0xffcbd5e1),
    cardText: const Color(0xff64748b),
    title: const Color(0xff1e293b),
    cardTextMuted: const Color(0xff9ca3af),
  );

  static final ContentTheme darkContentTheme = ContentTheme(
    background: const Color(0xff121212),
    onBackground: const Color(0xfff8fafc),
    primary: const Color(0xff35c75d),
    onPrimary: const Color(0xff0a1b10),
    primaryHover: const Color(0xff45d46d),
    surfaceHover: const Color(0xff1a3b25),
    borderStroke: const Color(0xff1f4d2e),
    textAccent: const Color(0xff7de69a),
    secondary: const Color(0xff132b1b),
    onSecondary: const Color(0xff7de69a),
    disabled: const Color(0xff334155),
    onDisabled: const Color(0xff475569),
    cardBorder: const Color(0xff1f4d2e),
    cardBackground: const Color(0xff1e1e1e),
    cardShadow: const Color(0xff020617),
    cardText: const Color(0xff9ca3af),
    title: const Color(0xfff8fafc),
    cardTextMuted: const Color(0xff6b7280),
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
