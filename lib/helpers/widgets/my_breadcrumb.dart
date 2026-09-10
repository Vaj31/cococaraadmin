import 'package:ccpladmin/helpers/theme/admin_theme.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_constant.dart';
import 'package:ccpladmin/helpers/widgets/my_responsive.dart';
import 'package:ccpladmin/helpers/widgets/my_router.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MyBreadcrumb extends StatelessWidget {
  final List<MyBreadcrumbItem> children;
  final bool hideOnMobile;
  final IconData? icon;

  MyBreadcrumb({
    super.key,
    required this.children,
    this.hideOnMobile = true,
    this.icon,
  }) {
    if (MyConstant.constant.defaultBreadCrumbItem != null) {
      children.insert(0, MyConstant.constant.defaultBreadCrumbItem!);
    }
  }

  IconData _getDefaultIcon(String? firstItemName) {
    if (icon != null) return icon!;
    if (children.isNotEmpty && children.first.icon != null) {
      return children.first.icon!;
    }
    final name = (firstItemName ?? '').toLowerCase().trim();
    if (name.contains('admin')) {
      return LucideIcons.settings;
    } else if (name.contains('process') || name.contains('po') || name.contains('order')) {
      return LucideIcons.layers;
    } else if (name.contains('master')) {
      return LucideIcons.database;
    } else if (name.contains('download')) {
      return LucideIcons.download;
    } else if (name.contains('dashboard') || name.contains('analytics')) {
      return LucideIcons.layout_dashboard;
    } else if (name.contains('sync')) {
      return LucideIcons.refresh_cw;
    }
    return LucideIcons.settings;
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    final leadingIcon = _getDefaultIcon(children.isNotEmpty ? children.first.name : null);

    List<Widget> list = [];

    // Leading icon
    list.add(
      Icon(
        leadingIcon,
        size: 14,
        color: contentTheme.cardTextMuted,
      ),
    );
    list.add(MySpacing.width(6));

    for (int i = 0; i < children.length; i++) {
      var item = children[i];
      final isLast = i == children.length - 1;
      final isActive = item.active || isLast;

      if (isActive) {
        list.add(
          MyText.bodySmall(
            item.name,
            color: contentTheme.onBackground,
            fontWeight: 600,
            fontSize: 13,
          ),
        );
      } else {
        Widget textWidget = MyText.bodySmall(
          item.name,
          color: contentTheme.cardTextMuted,
          fontSize: 13,
          fontWeight: 500,
        );

        if (item.route != null) {
          list.add(
            InkWell(
              onTap: () => MyRouter.pushReplacementNamed(context, item.route!),
              hoverColor: Colors.transparent,
              child: textWidget,
            ),
          );
        } else {
          list.add(textWidget);
        }
      }

      if (i < children.length - 1) {
        list.add(
          Padding(
            padding: MySpacing.x(6),
            child: MyText.bodySmall(
              ">",
              color: contentTheme.cardTextMuted,
              fontSize: 13,
            ),
          ),
        );
      }
    }

    return MyResponsive(builder: (_, _, type) {
      if (type.isMobile && hideOnMobile) {
        return const SizedBox();
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: list,
        );
      }
    });
  }
}
