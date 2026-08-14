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

class UploadDocScreen extends StatefulWidget {
  const UploadDocScreen({super.key});

  @override
  State<UploadDocScreen> createState() => _UploadDocScreenState();
}

class _UploadDocScreenState extends State<UploadDocScreen> with UIMixin {
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
                MyText.titleMedium("Upload Doc", fontSize: 18, fontWeight: 600),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Downloads'),
                    MyBreadcrumbItem(name: 'Upload Doc', active: true),
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
                  MyText.titleMedium("Upload Documents", fontWeight: 600),
                  MySpacing.height(8),
                  MyText.bodyMedium(
                    "Select or drag & drop files to upload to the server.",
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
                          LucideIcons.upload,
                          size: 48,
                          color: contentTheme.primary,
                        ),
                        MySpacing.height(16),
                        MyText.titleMedium(
                          "Drag and drop file here",
                          fontWeight: 600,
                        ),
                        MySpacing.height(4),
                        MyText.bodySmall(
                          "or click to browse from files",
                          muted: true,
                        ),
                        MySpacing.height(24),
                        MyButton.rounded(
                          onPressed: () {},
                          elevation: 0,
                          backgroundColor: contentTheme.primary,
                          child: MyText.labelLarge(
                            "Browse Files",
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
