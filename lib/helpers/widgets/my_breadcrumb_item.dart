import 'package:flutter/widgets.dart';

class MyBreadcrumbItem {
  final String name;
  final String? route;
  final bool active;
  final IconData? icon;

  MyBreadcrumbItem({
    required this.name,
    this.route,
    this.active = false,
    this.icon,
  });
}
