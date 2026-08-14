import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class DownloadDocScreen extends StatefulWidget {
  const DownloadDocScreen({super.key});

  @override
  State<DownloadDocScreen> createState() => _DownloadDocScreenState();
}

class _DownloadDocScreenState extends State<DownloadDocScreen> with UIMixin {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Download Doc",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Downloads'),
                    MyBreadcrumbItem(name: 'Download Doc', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyCard(
              paddingAll: 24,
              borderRadiusAll: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleMedium("Download Documents", fontWeight: 600),
                  MySpacing.height(8),
                  MyText.bodyMedium(
                    "View and download documents available on the server.",
                    muted: true,
                  ),
                  MySpacing.height(24),
                  Container(
                    width: double.infinity,
                    padding: MySpacing.all(48),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: contentTheme.primary.withAlpha(80),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: contentTheme.primary.withAlpha(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.download,
                          size: 48,
                          color: contentTheme.primary,
                        ),
                        MySpacing.height(16),
                        MyText.titleMedium(
                          "No downloadable documents found",
                          fontWeight: 600,
                        ),
                        MySpacing.height(4),
                        MyText.bodySmall(
                          "Documents will appear here once they are generated or uploaded.",
                          muted: true,
                        ),
                        MySpacing.height(24),
                        MyButton.rounded(
                          onPressed: () {},
                          elevation: 0,
                          backgroundColor: contentTheme.primary,
                          child: MyText.labelLarge(
                            "Refresh List",
                            color: contentTheme.onPrimary,
                            fontWeight: 600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
