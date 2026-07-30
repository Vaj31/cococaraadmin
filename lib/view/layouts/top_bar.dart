import 'package:ccpladmin/helpers/services/localizations/language.dart';
import 'package:ccpladmin/helpers/theme/app_notifier.dart';
import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_text_style.dart';
import 'package:ccpladmin/images.dart';
import 'package:ccpladmin/widgets/custom_pop_menu.dart';
import 'package:ccpladmin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/main.dart';
import 'package:universal_html/html.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
  });

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>
    with SingleTickerProviderStateMixin, UIMixin {
  Function? languageHideFn;
  bool isFullScreen = false, isLeftBarCondensed = false;
  int isNotificationTab = 0;

  void goFullScreen() {
    isFullScreen
        ? document.exitFullscreen()
        : document.documentElement!.requestFullscreen();
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  void leftBarCondensedToggle() {
    ThemeCustomizer.toggleLeftBarCondensed();
    isLeftBarCondensed = !isLeftBarCondensed;
    setState(() {});
  }

  void onChangeNotificationTabBar(int id) {
    isNotificationTab = id;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MyCard(
      shadow: MyShadow(position: MyShadowPosition.bottomRight, elevation: 0.5),
      height: 60,
      borderRadiusAll: 0,
      padding: MySpacing.x(24),
      color: topBarTheme.background.withAlpha(246),
      child: Row(
        children: [
          InkWell(
              splashColor: colorScheme.onSurface,
              highlightColor: colorScheme.onSurface,
              onTap: () => leftBarCondensedToggle(),
              child: Icon(
                !isLeftBarCondensed ? Icons.menu : Icons.arrow_forward_outlined,
                color: topBarTheme.onBackground,
              )),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () => searchModal(context),
                    child: Icon(LucideIcons.search, size: 20)),
                MySpacing.width(24),
                CustomPopupMenu(
                  backdrop: true,
                  hideFn: (hide) => languageHideFn = hide,
                  onChange: (_) {},
                  offsetX: -36,
                  offsetY: 20,
                  menu: MyContainer(
                      paddingAll: 0,
                      borderRadiusAll: 4,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SvgPicture.asset(
                          'assets/lang/${ThemeCustomizer.instance.currentLanguage.locale.languageCode}.svg',
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          height: 18)),
                  menuBuilder: (_) => buildLanguageSelector(),
                ),
                MySpacing.width(24),
                CustomPopupMenu(
                    backdrop: true,
                    onChange: (_) {},
                    offsetX: -120,
                    offsetY: 21,
                    menu: Icon(LucideIcons.bell, size: 20),
                    menuBuilder: (_) => buildNotifications()),
                MySpacing.width(24),
                InkWell(
                    onTap: goFullScreen,
                    child: Icon(
                        isFullScreen
                            ? LucideIcons.minimize
                            : LucideIcons.maximize,
                        size: 20)),
                MySpacing.width(24),
                InkWell(
                  onTap: () {
                    ThemeCustomizer.setTheme(
                        ThemeCustomizer.instance.theme == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark);
                  },
                  child: Icon(
                      ThemeCustomizer.instance.theme == ThemeMode.dark
                          ? LucideIcons.sun
                          : LucideIcons.moon,
                      size: 20,
                      color: topBarTheme.onBackground),
                ),
                MySpacing.width(24),
                CustomPopupMenu(
                  backdrop: true,
                  onChange: (_) {},
                  offsetX: -20,
                  offsetY: 0,
                  menu: Padding(
                    padding: MySpacing.xy(8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyContainer.rounded(
                            paddingAll: 0,
                            child: Image.asset(
                              Images.avatars[1],
                              height: 28,
                              width: 28,
                              fit: BoxFit.cover,
                            )),
                        MySpacing.width(8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.labelLarge("Tylor", fontWeight: 600),
                            MyText.labelSmall("Web Designer", fontWeight: 600),
                          ],
                        )
                      ],
                    ),
                  ),
                  menuBuilder: (_) => buildAccountMenu(),
                  hideFn: (hide) => languageHideFn = hide,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void searchModal(BuildContext context) {
    Widget otherResultsData(String image, name, email) {
      return Row(
        children: [
          MyContainer(
            height: 40,
            width: 40,
            paddingAll: 0,
            borderRadiusAll: 8,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.asset(image, fit: BoxFit.cover),
          ),
          MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(name, fontWeight: 600),
                MyText.bodySmall(email, fontWeight: 600, muted: true)
              ],
            ),
          ),
          MyContainer.bordered(
            padding: MySpacing.xy(12, 8),
            onTap: () {},
            child: Icon(LucideIcons.message_square, size: 18),
          )
        ],
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        elevation: 0.5,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        alignment: Alignment.center,
        actions: [
          Padding(
            padding: MySpacing.xy(12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 450,
                  child: buildSearch(),
                ),
                MySpacing.height(12),
                MyText.labelLarge("Result", fontWeight: 600),
                MySpacing.height(12),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: [
                    MyContainer(
                      borderRadiusAll: 20,
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.secondary.withAlpha(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.users, size: 16),
                          MySpacing.width(4),
                          MyText.bodySmall("People", fontWeight: 600)
                        ],
                      ),
                    ),
                    MyContainer(
                      borderRadiusAll: 20,
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.secondary.withAlpha(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.scroll_text, size: 16),
                          MySpacing.width(4),
                          MyText.bodySmall("Document", fontWeight: 600)
                        ],
                      ),
                    ),
                    MyContainer(
                      borderRadiusAll: 20,
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.secondary.withAlpha(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.paperclip, size: 16),
                          MySpacing.width(4),
                          MyText.bodySmall("Attachments", fontWeight: 600)
                        ],
                      ),
                    )
                  ],
                ),
                MySpacing.height(12),
                MyText.labelSmall("Best Match", fontWeight: 600),
                MySpacing.height(12),
                MyContainer.bordered(
                  borderRadiusAll: 8,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Row(
                    children: [
                      MyContainer(
                        height: 50,
                        width: 50,
                        paddingAll: 0,
                        borderRadiusAll: 8,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child:
                            Image.asset(Images.avatars[8], fit: BoxFit.cover),
                      ),
                      MySpacing.width(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("Kevin", fontWeight: 600),
                          MyText.bodySmall("kevin123@gmail.com",
                              fontWeight: 600, muted: true)
                        ],
                      ),
                      Spacer(),
                      MyContainer.bordered(
                        padding: MySpacing.xy(12, 8),
                        onTap: () {},
                        child: MyText.bodyMedium("Founder", fontWeight: 600),
                      ),
                      MySpacing.width(12),
                      MyContainer.bordered(
                        padding: MySpacing.xy(12, 8),
                        onTap: () {},
                        child: Icon(LucideIcons.message_square, size: 18),
                      ),
                    ],
                  ),
                ),
                MySpacing.height(12),
                MyText.labelSmall("Other Results",
                    fontWeight: 600, muted: true),
                MySpacing.height(12),
                otherResultsData(Images.avatars[1], "Anna", "anna@gmail.com"),
                MySpacing.height(16),
                otherResultsData(
                    Images.avatars[2], "Bernadette", "bernadette234@gmail.com"),
                MySpacing.height(16),
                otherResultsData(
                    Images.avatars[3], "Katherine", "katherine@gmail.com"),
                MySpacing.height(16),
                otherResultsData(
                    Images.avatars[4], "Samantha", "samantha238@gmaol.com"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearch() {
    return TextFormField(
      maxLines: 1,
      style: MyTextStyle.bodyMedium(),
      decoration: InputDecoration(
          hintText: "Search",
          filled: true,
          fillColor: contentTheme.secondary.withAlpha(36),
          hintStyle: MyTextStyle.bodySmall(xMuted: true),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          prefixIcon: Align(
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.search,
                size: 14,
              )),
          prefixIconConstraints: BoxConstraints(
              minWidth: 36, maxWidth: 36, minHeight: 32, maxHeight: 32),
          contentPadding: contentSpacing,
          isCollapsed: true,
          floatingLabelBehavior: FloatingLabelBehavior.never),
    );
  }

  Widget buildLanguageSelector() {
    return MyContainer(
      borderRadiusAll: 8,
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Language.languages
            .map((language) => MyButton.text(
                  padding: MySpacing.xy(8, 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashColor: contentTheme.onBackground.withAlpha(20),
                  onPressed: () async {
                    languageHideFn?.call();
                    await ProviderScope.containerOf(context)
                        .read(appNotifierProvider)
                        .changeLanguage(language, notify: true);
                    ThemeCustomizer.notify();
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      MyContainer(
                          borderRadiusAll: 4,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          paddingAll: 0,
                          child: SvgPicture.asset(
                              'assets/lang/${language.locale.languageCode}.svg',
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              height: 14,
                              width: 18)),
                      MySpacing.width(8),
                      MyText.labelMedium(language.languageName)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildNotifications() {
    Widget notificationData(IconData icon, String notificationDetail, time) {
      return MyContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyContainer.rounded(
              color: contentTheme.primary,
              paddingAll: 0,
              height: 32,
              width: 32,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Icon(icon, size: 16, color: contentTheme.onPrimary),
            ),
            MySpacing.width(12),
            Expanded(
              child: MyText.bodyMedium(notificationDetail,
                  fontWeight: 600, maxLines: 2),
            ),
            MySpacing.width(12),
            MyText.bodySmall(time, fontWeight: 600, xMuted: true)
          ],
        ),
      );
    }

    return MyContainer(
      paddingAll: 0,
      borderRadiusAll: 8,
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          notificationData(
              LucideIcons.shield_check, "The Update has finished", "1 min ago"),
          notificationData(
              LucideIcons.package_check, "New Update is available", "1 hr ago"),
          notificationData(
              LucideIcons.feather, "New feature is included", "1 day ago"),
          notificationData(
              LucideIcons.list_ordered, "Your Order is received", "1 week ago"),
          notificationData(
              LucideIcons.key, "Your account password changes", "1 month ago"),
        ],
      ),
    );
  }

  Widget buildAccountMenu() {
    return MyContainer(
      borderRadiusAll: 8,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyButton(
            onPressed: () => {},
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            borderRadiusAll: AppStyle.buttonRadius.medium,
            padding: MySpacing.xy(8, 4),
            splashColor: colorScheme.onSurface.withAlpha(20),
            backgroundColor: Colors.transparent,
            child: Row(
              children: [
                Icon(
                  LucideIcons.user,
                  size: 14,
                  color: contentTheme.onBackground,
                ),
                MySpacing.width(8),
                MyText.labelMedium(
                  "My Account",
                  fontWeight: 600,
                )
              ],
            ),
          ),
          MySpacing.height(8),
          MyButton(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => {},
            borderRadiusAll: AppStyle.buttonRadius.medium,
            padding: MySpacing.xy(8, 4),
            splashColor: colorScheme.onSurface.withAlpha(20),
            backgroundColor: Colors.transparent,
            child: Row(
              children: [
                Icon(LucideIcons.settings,
                    size: 14, color: contentTheme.onBackground),
                MySpacing.width(8),
                MyText.labelMedium("Settings", fontWeight: 600)
              ],
            ),
          ),
          MySpacing.height(8),
          MyButton(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              languageHideFn?.call();
              AuthService.logout().whenComplete(() {
                Get.offAllNamed('/auth/login');
              });
            },
            borderRadiusAll: AppStyle.buttonRadius.medium,
            padding: MySpacing.xy(8, 4),
            splashColor: contentTheme.danger.withAlpha(28),
            backgroundColor: Colors.transparent,
            child: Row(
              children: [
                Icon(LucideIcons.log_out, size: 14, color: contentTheme.danger),
                MySpacing.width(8),
                MyText.labelMedium("Log out",
                    fontWeight: 600, color: contentTheme.danger)
              ],
            ),
          )
        ],
      ),
    );
  }
}
