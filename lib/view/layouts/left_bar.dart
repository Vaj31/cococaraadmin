import 'package:ccpladmin/helpers/extensions/string.dart';
import 'package:ccpladmin/helpers/services/url_service.dart';
import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/images.dart';
import 'package:ccpladmin/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ccpladmin/services/auth_service.dart';

typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static void attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static void detachListener(String key) {
    observers.remove(key);
  }

  static void notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

class LeftBarScope extends InheritedWidget {
  final Animation<double> animation;
  final bool isCondensed;

  const LeftBarScope({
    super.key,
    required this.animation,
    required this.isCondensed,
    required super.child,
  });

  static LeftBarScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LeftBarScope>();
  }

  @override
  bool updateShouldNotify(LeftBarScope oldWidget) {
    return oldWidget.isCondensed != isCondensed ||
        oldWidget.animation != animation;
  }
}

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = false});

  @override
  _LeftBarState createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar>
    with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeOutCubic,
  );
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animController.value = widget.isCondensed ? 0.0 : 1.0;
  }

  @override
  void didUpdateWidget(LeftBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCondensed != widget.isCondensed) {
      if (widget.isCondensed) {
        _animController.reverse();
      } else {
        _animController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final Color borderColor = isDark
        ? const Color(0xFF1F4D2E)
        : const Color(0xFFB7E4C4).withValues(alpha: 0.6);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double currentWidth = 60.0 + 190.0 * _animation.value;

          return Container(
            width: currentWidth,
            decoration: BoxDecoration(
              color: leftBarTheme.background,
              border: Border(
                right: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          );
        },
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 250,
          maxWidth: 250,
          child: LeftBarScope(
            animation: _animation,
            isCondensed: widget.isCondensed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(borderColor),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        labelWidget("dashboard".tr(), _animation),
                        NavigationItem(
                          iconData: LucideIcons.layout_dashboard,
                          title: "Dashboard",
                          isCondensed: widget.isCondensed,
                          route: '/dashboard/analytics',
                        ),
                        labelWidget("masters".tr(), _animation),
                        NavigationItem(
                          iconData: LucideIcons.users,
                          title: "Customer Master",
                          isCondensed: widget.isCondensed,
                          route: '/masters/customers',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.users,
                          title: "Suppliers",
                          isCondensed: widget.isCondensed,
                          route: '/masters/suppliers',
                        ),
                        labelWidget("processing".tr(), _animation),
                        NavigationItem(
                          iconData: LucideIcons.refresh_cw,
                          title: "Google Sync",
                          isCondensed: widget.isCondensed,
                          route: '/processing/google_sync',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.shopping_bag,
                          title: "Purchase Order",
                          isCondensed: widget.isCondensed,
                          route: '/po/polist',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.truck,
                          title: "Shipping Schedule",
                          isCondensed: widget.isCondensed,
                          route: '/ss/shipping_schedule',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.package,
                          title: "Generate Pallet",
                          isCondensed: widget.isCondensed,
                          route: '/po/create_pallet',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.layers,
                          title: "Pallet List",
                          isCondensed: widget.isCondensed,
                          route: '/masters/pallet_list',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.list,
                          title: "Pending Order List",
                          isCondensed: widget.isCondensed,
                          route: '/po/pending_order_list',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.tag,
                          title: "Pallet Stickering",
                          isCondensed: widget.isCondensed,
                          route: '/palletsticker/pallet_stickering',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.file_text,
                          title: "Production Report",
                          isCondensed: widget.isCondensed,
                          route: '/processing/production_report',
                        ),
                        labelWidget("administration".tr(), _animation),
                        NavigationItem(
                          iconData: LucideIcons.users,
                          title: "User Management",
                          isCondensed: widget.isCondensed,
                          route: '/administration/user_management',
                        ),
                        labelWidget("Assets", _animation),
                        NavigationItem(
                          iconData: LucideIcons.folder,
                          title: "Asset Library",
                          isCondensed: widget.isCondensed,
                          route: '/assets/asset_library',
                        ),
                        NavigationItem(
                          iconData: LucideIcons.log_out,
                          title: "Log out",
                          isCondensed: widget.isCondensed,
                          onTap: () {
                            AuthService.logout().whenComplete(() {
                              Get.offAllNamed('/auth/login');
                            });
                          },
                        ),
                        MySpacing.height(12),
                        SizedBox(
                          width: 60,
                          height: 48,
                          child: FadeTransition(
                            opacity: ReverseAnimation(_animation),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  UrlService.goToPagger();
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.deepPurple,
                                        Colors.lightBlue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.download,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        MySpacing.height(16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color borderColor) {
    return Container(
      height: 62,
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/dashboard/analytics');
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Full brand logo (smoothly slides in from left)
            FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.15, 0),
                  end: Offset.zero,
                ).animate(_animation),
                child: SizedBox(
                  width: 250,
                  child: Center(
                    child: Image.asset(
                      Images.logo,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Small icon logo (centered in the 60px mini bar)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 60,
              child: FadeTransition(
                opacity: ReverseAnimation(_animation),
                child: Center(
                  child: Image.asset(
                    Images.logoSm,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget labelWidget(String label, Animation<double> animation) {
    final bool isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.25, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuWidget extends StatefulWidget {
  final IconData iconData;
  final String title;
  final bool isCondensed;
  final bool active;
  final String? route;
  final List<MenuItem> children;

  const MenuWidget({
    super.key,
    required this.iconData,
    required this.title,
    this.isCondensed = false,
    this.active = false,
    this.children = const [],
    this.route,
  });

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
    );
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(bool value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.children.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (hide) => hideFn = hide,
        onChange: (value) {
          popupShowing = value;
        },
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },

          /// Small Side Bar
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(4, 0, 8, 8),
            borderRadiusAll: 8,
            padding: MySpacing.xy(0, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyContainer(
                  height: 26,
                  width: 6,
                  paddingAll: 0,
                  color: isActive || isHover
                      ? leftBarTheme.activeItemColor
                      : Colors.transparent,
                ),
                MySpacing.width(12),
                Icon(
                  widget.iconData,
                  color: (isHover || isActive)
                      ? leftBarTheme.activeItemColor
                      : leftBarTheme.onBackground,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        menuBuilder: (_) => MyContainer(
          borderRadiusAll: 8,
          paddingAll: 8,
          width: 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 2, 12, 2),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF132B1B) : const Color(0xFFEAF7EE))
                : (isHover
                    ? (isDark
                        ? const Color(0xFF1A3B25)
                        : const Color(0x0A30AE52))
                    : Colors.transparent),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border(
              left: BorderSide(
                color: isActive
                    ? (isDark
                        ? const Color(0xFF35C75D)
                        : const Color(0xFF30AE52))
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: ListTileTheme(
            contentPadding: EdgeInsets.zero,
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              initiallyExpanded: isActive,
              maintainState: true,
              onExpansionChanged: (value) {
                LeftbarObserver.notifyAll(widget.title);
                onChangeExpansion(value);
              },
              trailing: RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  LucideIcons.chevron_down,
                  size: 16,
                  color: isActive || isHover
                      ? (isDark
                          ? const Color(0xFF35C75D)
                          : const Color(0xFF22783A))
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF6B7280)),
                ),
              ),
              iconColor: isDark
                  ? const Color(0xFF35C75D)
                  : const Color(0xFF22783A),
              childrenPadding: const EdgeInsets.only(left: 8),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.iconData,
                    size: 19,
                    color: isActive
                        ? (isDark
                            ? const Color(0xFF35C75D)
                            : const Color(0xFF22783A))
                        : (isHover
                            ? (isDark
                                ? const Color(0xFF35C75D)
                                : const Color(0xFF30AE52))
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF6B7280))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive || isHover
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? (isDark
                                ? const Color(0xFF35C75D)
                                : const Color(0xFF22783A))
                            : (isHover
                                ? (isDark
                                    ? const Color(0xFF35C75D)
                                    : const Color(0xFF111827))
                                : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF6B7280))),
                      ),
                    ),
                  ),
                ],
              ),
              collapsedBackgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              backgroundColor: Colors.transparent,
              children: widget.children,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    LeftbarObserver.detachListener(widget.title);
  }
}

class MenuItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;
  final List<MenuItem> childrenMenuWidget;

  const MenuItem({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
    this.childrenMenuWidget = const [],
  });

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
    );
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(bool value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.childrenMenuWidget.any(
      (element) => element.route == route,
    );
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    if (widget.childrenMenuWidget.isEmpty) {
      return GestureDetector(
        onTap: () {
          if (widget.route != null) {
            Get.toNamed(widget.route!);
            // MyRouter.pushReplacementNamed(context, widget.route!, arguments: 1);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 2, 12, 2),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark
                      ? const Color(0xFF132B1B)
                      : const Color(0xFFEAF7EE))
                  : (isHover
                      ? (isDark
                          ? const Color(0xFF1A3B25)
                          : const Color(0x0A30AE52))
                      : Colors.transparent),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border(
                left: BorderSide(
                  color: isActive
                      ? (isDark
                          ? const Color(0xFF35C75D)
                          : const Color(0xFF30AE52))
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.dot,
                  size: 16,
                  color: isActive
                      ? (isDark
                          ? const Color(0xFF35C75D)
                          : const Color(0xFF22783A))
                      : (isHover
                          ? (isDark
                              ? const Color(0xFF35C75D)
                              : const Color(0xFF30AE52))
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF6B7280))),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isActive
                        ? (isDark
                            ? const Color(0xFF35C75D)
                            : const Color(0xFF22783A))
                        : (isHover
                            ? (isDark
                                ? const Color(0xFF35C75D)
                                : const Color(0xFF111827))
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF6B7280))),
                    fontWeight: isActive || isHover ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (hide) => hideFn = hide,
        onChange: (value) {
          popupShowing = value;
        },
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(16, 0, 16, 8),
            color: isActive || isHover
                ? leftBarTheme.activeItemBackground
                : Colors.transparent,
            borderRadiusAll: 8,
            padding: MySpacing.xy(8, 8),
            child: Center(
              child: Icon(
                widget.iconData,
                color: (isHover || isActive)
                    ? leftBarTheme.activeItemColor
                    : leftBarTheme.onBackground,
                size: 20,
              ),
            ),
          ),
        ),
        menuBuilder: (_) => MyContainer(
          borderRadiusAll: 8,
          paddingAll: 8,
          width: 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: widget.childrenMenuWidget,
          ),
        ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(24, 0, 16, 0),
          paddingAll: 0,
          borderRadiusAll: 8,
          child: ListTileTheme(
            contentPadding: EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
              tilePadding: MySpacing.zero,
              initiallyExpanded: isActive,
              maintainState: true,
              onExpansionChanged: (value) {
                LeftbarObserver.notifyAll(widget.title);
                onChangeExpansion(value);
              },
              trailing: RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  LucideIcons.chevron_down,
                  size: 18,
                  color: leftBarTheme.onBackground,
                ),
              ),
              iconColor: leftBarTheme.activeItemColor,
              childrenPadding: MySpacing.x(12),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.iconData,
                    size: 20,
                    color: isHover || isActive
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.onBackground,
                  ),
                  MySpacing.width(18),
                  Expanded(
                    child: MyText.labelLarge(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      color: isHover || isActive
                          ? leftBarTheme.activeItemColor
                          : leftBarTheme.onBackground,
                    ),
                  ),
                ],
              ),
              collapsedBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              backgroundColor: Colors.transparent,
              children: widget.childrenMenuWidget,
            ),
          ),
        ),
      );
    }
  }
}

class NavigationItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;
  final VoidCallback? onTap;
  final String? badge;

  const NavigationItem({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
    this.onTap,
    this.badge,
  });

  @override
  _NavigationItemState createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final scope = LeftBarScope.of(context);
    final Animation<double>? animation = scope?.animation;
    final bool isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final bool isActive =
        widget.route != null && UrlService.getCurrentUrl() == widget.route;

    // Active Colors
    final Color activeBg =
        isDark ? const Color(0xFF132B1B) : const Color(0xFFEAF7EE);
    final Color activeIndicator =
        isDark ? const Color(0xFF35C75D) : const Color(0xFF30AE52);
    final Color activeTextIcon =
        isDark ? const Color(0xFF35C75D) : const Color(0xFF22783A);

    // Hover Colors (Inactive)
    final Color hoverBg = isDark
        ? const Color(0xFF1A3B25)
        : const Color(0x0A30AE52);
    final Color hoverText =
        isDark ? const Color(0xFF35C75D) : const Color(0xFF111827);
    final Color hoverIcon =
        isDark ? const Color(0xFF35C75D) : const Color(0xFF30AE52);

    // Inactive Default Colors
    final Color defaultText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final Color defaultIcon =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    // Resolved styles
    final Color bgColor = isActive
        ? activeBg
        : (isHover ? hoverBg : Colors.transparent);
    final Color textColor = isActive
        ? activeTextIcon
        : (isHover ? hoverText : defaultText);
    final Color iconColor = isActive
        ? activeTextIcon
        : (isHover ? hoverIcon : defaultIcon);
    final FontWeight fontWeight =
        isActive ? FontWeight.w600 : FontWeight.w500;

    return Tooltip(
      message: widget.isCondensed ? widget.title : '',
      waitDuration: const Duration(milliseconds: 350),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else if (widget.route != null) {
            Get.toNamed(widget.route!);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            if (!isHover) setState(() => isHover = true);
          },
          onExit: (_) {
            if (isHover) setState(() => isHover = false);
          },
          child: SizedBox(
            height: 40,
            width: 250,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 1. Background highlight & border indicator
                if (animation != null)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        final double progress = animation.value;
                        final double left = 6.0 * (1.0 - progress);
                        final double right = 12.0 + 184.0 * (1.0 - progress);
                        final double radius = 8.0 * (1.0 - progress);

                        return Padding(
                          padding: EdgeInsets.fromLTRB(left, 1, right, 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(8),
                                bottomRight: const Radius.circular(8),
                                topLeft: Radius.circular(radius),
                                bottomLeft: Radius.circular(radius),
                              ),
                              border: Border(
                                left: BorderSide(
                                  color: isActive
                                      ? activeIndicator.withValues(
                                          alpha: progress.clamp(0.0, 1.0))
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Positioned(
                    left: widget.isCondensed ? 6 : 0,
                    right: widget.isCondensed ? 196 : 12,
                    top: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(8),
                          bottomRight: const Radius.circular(8),
                          topLeft: Radius.circular(widget.isCondensed ? 8 : 0),
                          bottomLeft: Radius.circular(widget.isCondensed ? 8 : 0),
                        ),
                        border: Border(
                          left: BorderSide(
                            color: isActive && !widget.isCondensed
                                ? activeIndicator
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 2. Active indicator pill when condensed
                if (isActive)
                  Positioned(
                    left: 0,
                    top: 9,
                    bottom: 9,
                    width: 3,
                    child: animation != null
                        ? FadeTransition(
                            opacity: ReverseAnimation(animation),
                            child: Container(
                              decoration: BoxDecoration(
                                color: activeIndicator,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                            ),
                          )
                        : (widget.isCondensed
                            ? Container(
                                decoration: BoxDecoration(
                                  color: activeIndicator,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                              )
                            : const SizedBox()),
                  ),

                // 3. Icon slot: exactly centered at x = 30px
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 60,
                  child: Center(
                    child: widget.iconData != null
                        ? Icon(
                            widget.iconData,
                            color: iconColor,
                            size: 19,
                          )
                        : const SizedBox(width: 19, height: 19),
                  ),
                ),

                // 4. Label text & badge: slides in/out horizontally & fades
                Positioned(
                  left: 56,
                  right: 18,
                  top: 0,
                  bottom: 0,
                  child: animation != null
                      ? FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.25, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: fontWeight,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (widget.badge != null &&
                                      widget.badge!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF35C75D)
                                            : const Color(0xFF30AE52),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.badge!,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFF0A1B10)
                                              : const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                      : (!widget.isCondensed
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: fontWeight,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (widget.badge != null &&
                                      widget.badge!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF35C75D)
                                            : const Color(0xFF30AE52),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.badge!,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFF0A1B10)
                                              : const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : const SizedBox()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
