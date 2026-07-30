import 'package:ccpladmin/controller/layout/auth_layout_2_controller.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_responsive.dart';
import 'package:ccpladmin/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metaballs/dart_ui_real.dart';

class AuthLayout2 extends StatefulWidget {
  final Widget child;

  const AuthLayout2({super.key, required this.child});

  @override
  State<AuthLayout2> createState() => _AuthLayout2State();
}

class _AuthLayout2State extends State<AuthLayout2> with UIMixin {
  AuthLayout2Controller controller = Get.put(AuthLayout2Controller());

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile ? mobileScreen() : largeScreen();
          });
    });
  }

  Widget mobileScreen() {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        fit: StackFit.expand,
        alignment: Alignment.centerRight,
        children: [
          Image.asset(Images.auth2Background, fit: BoxFit.cover),
          Positioned(
              right: 24,
              top: 24,
              bottom: 24,
              left: 24,
              child: BlurryContainer(width: 400, child: widget.child)),
        ],
      ),
    );
  }

  Widget largeScreen() {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        fit: StackFit.expand,
        alignment: Alignment.centerRight,
        children: [
          Image.asset(Images.auth2Background, fit: BoxFit.cover),
          Positioned(
              right: 24,
              top: 24,
              bottom: 24,
              child: BlurryContainer(width: 450, child: widget.child)),
        ],
      ),
    );
  }
}

class BlurryContainer extends StatelessWidget {
  final Widget child;
  final double width;

  BlurryContainer({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RoundedRectangleClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: MyContainer(
            width: width,
            paddingAll: 24,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: Colors.black.withValues(alpha: 0.3),
            borderRadiusAll: 12,
            child: child),
      ),
    );
  }
}

class RoundedRectangleClipper extends CustomClipper<Path> {
  final double radius;

  RoundedRectangleClipper({this.radius = 12.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
