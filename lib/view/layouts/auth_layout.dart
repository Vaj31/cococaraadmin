import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:ccpladmin/controller/layout/auth_layout_controller.dart';
import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_responsive.dart';
import 'package:ccpladmin/helpers/widgets/my_screen_media_type.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/images.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthLayout extends StatefulWidget {
  final Widget? child;

  AuthLayout({super.key, this.child});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> with UIMixin {
  final AuthLayoutController controller = AuthLayoutController();

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile
                ? mobileScreen(context)
                : largeScreen(context);
          });
    });
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: Container(
        padding: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        color: theme.cardTheme.color,
        child: SingleChildScrollView(
          key: controller.scrollKey,
          child: widget.child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
        key: controller.scaffoldKey,
        body: Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            Stack(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              fit: StackFit.expand,
              children: [
                Image.asset(
                  Images.authBackground,
                  fit: BoxFit.cover,
                ),
                Container(color: const Color.fromARGB(255, 37, 61, 45).withValues(alpha: .6))
              ],
            ),
            Positioned.fill(
              child: FloatingBubbles.alwaysRepeating(
                noOfBubbles: 100,
                colorsOfBubbles: [
                  const Color.fromARGB(255, 114, 217, 80),
                  Colors.red,
                  const Color.fromARGB(255, 0, 255, 0),
                ],
                sizeFactor: 0.010,
                paintingStyle: PaintingStyle.fill,
                shape: BubbleShape.roundedRectangle,
                speed: BubbleSpeed.slow,
              ),
            ),
            Container(
              margin: MySpacing.top(100),
              width: MediaQuery.of(context).size.width,
              child: MyFlex(
                wrapAlignment: WrapAlignment.center,
                wrapCrossAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  MyFlexItem(
                    sizes: "xxl-8 lg-8 md-9 sm-10",
                    child: MyContainer(
                      borderRadiusAll: 8,
                      height: MediaQuery.of(context).size.height * .73,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyFlex(
                          wrapAlignment: WrapAlignment.center,
                          wrapCrossAlignment: WrapCrossAlignment.start,
                          runAlignment: WrapAlignment.center,
                          runSpacing: 0,
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                                sizes: "lg-6",
                                child: widget.child ?? Container()),
                            MyFlexItem(
                              sizes: "lg-6",
                              child: MyResponsive(
                                builder: (_, BoxConstraints _, type) {
                                  return type == MyScreenMediaType.xxl ||
                                          type == MyScreenMediaType.xl ||
                                          type == MyScreenMediaType.lg
                                      ? flexImage()
                                      : const SizedBox();
                                },
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  MyFlexItem flexImage() {
    return MyFlexItem(
        sizes: "lg-6",
        child: MyContainer(
          paddingAll: 0,
          borderRadiusAll: 8,
          height: MediaQuery.of(context).size.height * .7,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              Image.asset(
                Images.authBackground,
                fit: BoxFit.cover,
              ),
              // animatedCarousel(),
            ],
          ),
        ));
  }

  Widget animatedCarousel() {
    List<Widget> buildPageIndicatorStatic() {
      List<Widget> list = [];
      for (int i = 0; i < controller.animatedCarouselSize; i++) {
        list.add(i == controller.selectedAnimatedCarousel
            ? indicator(true)
            : indicator(false));
      }
      return list;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 100,
          child: Padding(
            padding: MySpacing.x(70),
            child: PageView(
              pageSnapping: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              scrollBehavior: AppScrollBehavior(),
              physics: ClampingScrollPhysics(),
              controller: controller.animatedPageController,
              onPageChanged: controller.onChangeAnimatedCarousel,
              children: <Widget>[
                MyText.bodySmall(
                  controller.dummyTexts[4],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  color: contentTheme.light,
                  fontWeight: 600,
                  letterSpacing: 1,
                ),
                MyText.bodySmall(
                  controller.dummyTexts[5],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  color: contentTheme.light,
                  fontWeight: 600,
                  letterSpacing: 1,
                ),
                MyText.bodySmall(
                  controller.dummyTexts[6],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  color: contentTheme.light,
                  fontWeight: 600,
                  letterSpacing: 1,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildPageIndicatorStatic(),
        ),
        MySpacing.height(20),
      ],
    );
  }

  Widget indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(140),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
