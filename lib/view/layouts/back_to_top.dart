import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class BackToTop extends StatefulWidget {
  final ScrollController scrollController;

  const BackToTop({required this.scrollController, super.key});

  @override
  State<BackToTop> createState() => _BackToTopState();
}

class _BackToTopState extends State<BackToTop> with UIMixin {
  bool showBackToTop = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController.hasClients ||
        widget.scrollController.positions.length > 1) {
      widget.scrollController.addListener(() {
        bool oldUpdate = showBackToTop;
        showBackToTop = widget.scrollController.offset > 10 ? true : false;
        if (oldUpdate != showBackToTop) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return showBackToTop
        ? MyContainer.rounded(
            onTap: () => widget.scrollController.animateTo(0,
                duration: Duration(milliseconds: 300), curve: Curves.linear),
            paddingAll: 0,
            height: 44,
            width: 44,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: contentTheme.primary,
            child: Icon(
              LucideIcons.move_up,
              size: 20,
              color: contentTheme.onPrimary,
            ),
          )
        : Text('');
  }
}
