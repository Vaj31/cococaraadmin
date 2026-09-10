import 'package:ccpladmin/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String? hint;
  final String Function(T)? itemLabel;
  final Widget Function(T item, bool isSelected)? leadingBuilder;
  final Widget? prefix;
  final double height;
  final double? width;
  final bool isExpanded;
  final bool enabled;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? menuMaxHeight;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.itemLabel,
    this.leadingBuilder,
    this.prefix,
    this.height = 44,
    this.width,
    this.isExpanded = false,
    this.enabled = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.menuMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    final hasValidValue = value != null && items.contains(value);
    final effectiveValue = hasValidValue
        ? value
        : (hint == null && items.isNotEmpty ? items.first : null);

    final isHint = effectiveValue == null && hint != null;
    final displayLabel = isHint
        ? hint!
        : (effectiveValue != null
            ? (itemLabel != null ? itemLabel!(effectiveValue) : effectiveValue.toString())
            : '');

    final leadingWidget = (effectiveValue != null && leadingBuilder != null)
        ? leadingBuilder!(effectiveValue, false)
        : prefix;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double? calculatedWidth = width ??
            (isExpanded && constraints.hasBoundedWidth ? constraints.maxWidth : null);

        return Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<T>(
            enabled: enabled && items.isNotEmpty,
            tooltip: '',
            position: PopupMenuPosition.under,
            elevation: 6,
            shadowColor: Colors.black.withAlpha(50),
            color: contentTheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: contentTheme.onBackground.withAlpha(20),
              ),
            ),
            constraints: calculatedWidth != null
                ? BoxConstraints(
                    minWidth: calculatedWidth,
                    maxWidth: calculatedWidth,
                    maxHeight: menuMaxHeight ?? 320,
                  )
                : BoxConstraints(
                    minWidth: 160,
                    maxHeight: menuMaxHeight ?? 320,
                  ),
            padding: EdgeInsets.zero,
            onSelected: onChanged,
            itemBuilder: (context) {
              return items.map((T item) {
                final isSelected = item == effectiveValue;
                final label = itemLabel != null ? itemLabel!(item) : item.toString();
                final leading =
                    leadingBuilder != null ? leadingBuilder!(item, isSelected) : null;

                return PopupMenuItem<T>(
                  value: item,
                  height: 38,
                  padding: EdgeInsets.zero,
                  child: _DropdownItemRow(
                    label: label,
                    isSelected: isSelected,
                    leading: leading,
                  ),
                );
              }).toList();
            },
            child: Opacity(
              opacity: enabled ? 1.0 : 0.6,
              child: Container(
                height: height,
                width: calculatedWidth,
                alignment: Alignment.center,
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: backgroundColor ?? contentTheme.background,
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor ?? contentTheme.onBackground.withAlpha(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment:
                      isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                  children: [
                    if (leadingWidget != null) ...[
                      leadingWidget,
                      const SizedBox(width: 8),
                    ],
                    if (isExpanded) ...[
                      Expanded(
                        child: Text(
                          displayLabel,
                          style: textStyle ??
                              TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isHint
                                    ? contentTheme.onBackground.withAlpha(120)
                                    : contentTheme.onBackground,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.chevron_down,
                        size: 16,
                        color: contentTheme.onBackground.withAlpha(150),
                      ),
                    ] else ...[
                      Text(
                        displayLabel,
                        style: textStyle ??
                            TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isHint
                                  ? contentTheme.onBackground.withAlpha(120)
                                  : contentTheme.onBackground,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.chevron_down,
                        size: 16,
                        color: contentTheme.onBackground.withAlpha(150),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownItemRow extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Widget? leading;

  const _DropdownItemRow({
    required this.label,
    required this.isSelected,
    this.leading,
  });

  @override
  State<_DropdownItemRow> createState() => _DropdownItemRowState();
}

class _DropdownItemRowState extends State<_DropdownItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    final isSelected = widget.isSelected;

    Color bg;
    if (isSelected) {
      bg = contentTheme.primary;
    } else if (_isHovered) {
      bg = contentTheme.onBackground.withAlpha(12);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : contentTheme.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.check,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
