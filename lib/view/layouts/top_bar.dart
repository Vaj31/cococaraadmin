import 'package:ccpladmin/helpers/services/localizations/language.dart';
import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
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
import 'package:ccpladmin/view/layouts/my_todo_drawer.dart';
import 'package:universal_html/html.dart' hide VoidCallback;

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

  Widget _buildSquareButton({
    required Widget child,
    required VoidCallback onTap,
    String? tooltip,
    Color? borderColorOverride,
    Color? bgOverride,
  }) {
    final isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final border = borderColorOverride ??
        (isDark
            ? const Color(0xFF1F4D2E)
            : const Color(0xFFB7E4C4).withValues(alpha: 0.8));
    final bg = bgOverride ??
        (isDark
            ? const Color(0xFF132B1B).withValues(alpha: 0.4)
            : Colors.white);

    Widget button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: isDark
          ? const Color(0xFF1A3B25)
          : const Color(0xFFEAF7EE),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1),
        ),
        child: child,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget buildMessages() {
    Widget messageItem(
        String avatar, String name, String preview, String time) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(avatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(time,
                style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return MyContainer(
      paddingAll: 0,
      borderRadiusAll: 8,
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Messages",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text("Mark all read",
                    style: TextStyle(
                        fontSize: 11, color: contentTheme.primary)),
              ],
            ),
          ),
          const Divider(height: 1),
          messageItem(Images.avatars[0], "Support Team",
              "Ticket #4092 resolved", "5m ago"),
          messageItem(Images.avatars[1], "Logistics Admin",
              "Supplier dispatch confirmed", "1h ago"),
          messageItem(Images.avatars[2], "Finance Desk",
              "Payment verification pending", "3h ago"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final borderColor = isDark
        ? const Color(0xFF1F4D2E)
        : const Color(0xFFB7E4C4).withValues(alpha: 0.8);

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: topBarTheme.background,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1F4D2E)
                : const Color(0xFFB7E4C4).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Menu Icon
          InkWell(
            splashColor: colorScheme.onSurface,
            highlightColor: colorScheme.onSurface,
            hoverColor: isDark
                ? const Color(0xFF1A3B25)
                : const Color(0xFFEAF7EE),
            onTap: () => leftBarCondensedToggle(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                LucideIcons.menu,
                size: 20,
                color: isDark
                    ? const Color(0xFF35C75D)
                    : const Color(0xFF22783A),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Middle Controls & Search
          _buildSquareButton(
            tooltip: "Refresh",
            onTap: () {
              setState(() {});
            },
            child: Icon(
              LucideIcons.rotate_cw,
              size: 16,
              color: topBarTheme.onBackground.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),
          _buildSquareButton(
            tooltip: "My To-Do",
            onTap: () => MyTodoDrawer.show(context),
            child: Icon(
              LucideIcons.sliders_horizontal,
              size: 16,
              color: topBarTheme.onBackground.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 12),
          // Search Box
          InkWell(
            onTap: () => searchModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 36,
              width: 210,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF7DE69A)
                        : const Color(0xFF22783A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Search...",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF132B1B)
                          : const Color(0xFFEAF7EE),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1F4D2E)
                            : const Color(0xFFB7E4C4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      "⌘ K",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF7DE69A)
                            : const Color(0xFF22783A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Right Actions
          // Language Selector
          CustomPopupMenu(
            backdrop: true,
            hideFn: (hide) => languageHideFn = hide,
            onChange: (_) {},
            offsetX: -36,
            offsetY: 20,
            menu: Tooltip(
              message: "Change Language",
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SvgPicture.asset(
                    'assets/lang/${ThemeCustomizer.instance.currentLanguage.locale.languageCode}.svg',
                    width: 19,
                    height: 14,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            menuBuilder: (_) => buildLanguageSelector(),
          ),
          const SizedBox(width: 8),

          // Full Screen Toggle
          _buildSquareButton(
            tooltip: isFullScreen ? "Exit Fullscreen" : "Fullscreen",
            onTap: goFullScreen,
            child: Icon(
              isFullScreen ? LucideIcons.minimize : LucideIcons.maximize,
              size: 16,
              color: topBarTheme.onBackground.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),

          // Dark Mode Toggle
          _buildSquareButton(
            tooltip: isDark ? "Light Mode" : "Dark Mode",
            onTap: () {
              ThemeCustomizer.setTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            child: Icon(
              isDark ? LucideIcons.sun : LucideIcons.moon,
              size: 16,
              color: topBarTheme.onBackground.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),

          // Notifications
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {},
            offsetX: -120,
            offsetY: 21,
            menu: Tooltip(
              message: "Notifications",
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(
                  LucideIcons.bell,
                  size: 16,
                  color: topBarTheme.onBackground.withValues(alpha: 0.85),
                ),
              ),
            ),
            menuBuilder: (_) => buildNotifications(),
          ),
          const SizedBox(width: 8),

          // Messages
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {},
            offsetX: -120,
            offsetY: 21,
            menu: Tooltip(
              message: "Messages",
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(
                  LucideIcons.message_square,
                  size: 16,
                  color: topBarTheme.onBackground.withValues(alpha: 0.85),
                ),
              ),
            ),
            menuBuilder: (_) => buildMessages(),
          ),
          const SizedBox(width: 14),

          // User Profile
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {},
            offsetX: -20,
            offsetY: 10,
            hideFn: (hide) => languageHideFn = hide,
            menu: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF35C75D)
                            : const Color(0xFF30AE52),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "B",
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF0A1B10)
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Barathvaj T",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: topBarTheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            menuBuilder: (_) => buildAccountMenu(),
          ),
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
