import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_form_validator.dart';
import 'package:ccpladmin/images.dart';
import 'package:ccpladmin/view/layouts/auth_layout.dart';
import 'package:ccpladmin/widgets/flow_kit_text_field.dart';
import 'package:ccpladmin/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final MyFormValidator basicV = MyFormValidator();
  final TextEditingController passwordController =
      TextEditingController(text: "password");
  final TextEditingController confirmPasswordController =
      TextEditingController(text: "password123");

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void onLogin() {
    if (basicV.validateForm()) {
      Get.offNamed('/dashboard/analytics');
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPassword = ref.watch(resetPasswordShowProvider);
    final confirmPassword = ref.watch(resetConfirmPasswordShowProvider);

    return AuthLayout(
      child: Padding(
        padding: MySpacing.x(MediaQuery.of(context).size.width * .03),
        child: Column(
          children: [
            MyContainer(
                height: 40,
                paddingAll: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(Images.logo, fit: BoxFit.cover, width: 150)),
            MySpacing.height(44),
            MyText.titleLarge("Reset Password", fontWeight: 600),
            MySpacing.height(12),
            MyText.bodyMedium(
                "Don't use a variation of an old password or any personal information",
                fontWeight: 600),
            MySpacing.height(24),
            buildField(showPassword, confirmPassword),
            MySpacing.height(24),
            MyButton.block(
                elevation: 0,
                borderRadiusAll: 8,
                padding: MySpacing.y(20),
                backgroundColor: contentTheme.primary,
                onPressed: onLogin,
                child: MyText.bodyMedium(
                  "Reset Password",
                  fontWeight: 600,
                  color: contentTheme.onPrimary,
                )),
          ],
        ),
      ),
    );
  }

  Widget buildField(bool showPassword, bool confirmPassword) {
    return Form(
      key: basicV.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("Password", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            hintText: "Password",
            obscureText: !showPassword,
            suffixIcon: InkWell(
              onTap: () => ref.read(resetPasswordShowProvider.notifier).state = !showPassword,
              child: Icon(
                  !showPassword ? LucideIcons.eye_off : LucideIcons.eye,
                  size: 20),
            ),
          ),
          MySpacing.height(20),
          MyText.bodyMedium("Confirm Password", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a confirm password';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            controller: confirmPasswordController,
            hintText: "Confirm Password",
            obscureText: !confirmPassword,
            suffixIcon: InkWell(
              onTap: () => ref.read(resetConfirmPasswordShowProvider.notifier).state = !confirmPassword,
              child: Icon(
                  !confirmPassword ? LucideIcons.eye_off : LucideIcons.eye,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
