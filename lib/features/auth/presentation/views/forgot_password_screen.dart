import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_form_validator.dart';
import 'package:ccpladmin/helpers/widgets/my_validators.dart';
import 'package:ccpladmin/images.dart';
import 'package:ccpladmin/view/layouts/auth_layout.dart';
import 'package:ccpladmin/widgets/flow_kit_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final MyFormValidator basicValidator = MyFormValidator();

  @override
  void initState() {
    super.initState();
    basicValidator.addField(
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(text: "demo@gmail.com"),
    );
  }

  @override
  void dispose() {
    basicValidator.getController('email')?.dispose();
    super.dispose();
  }

  void onLogin() {
    if (basicValidator.validateForm()) {
      Get.toNamed('/auth/reset_password');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            MyText.titleLarge("Forgot Password", fontWeight: 600),
            MySpacing.height(12),
            MyText.bodyMedium(
                "Please, enter the email associated with your account and we'll send an email with link, where you can change your password.",
                fontWeight: 600),
            MySpacing.height(24),
            buildField(),
            MySpacing.height(24),
            MyButton.block(
                elevation: 0,
                padding: MySpacing.y(20),
                borderRadiusAll: 8,
                backgroundColor: contentTheme.primary,
                onPressed: onLogin,
                child: MyText.bodyMedium(
                  "Forgot Password",
                  fontWeight: 600,
                  color: contentTheme.onPrimary,
                )),
            MyButton.text(
                onPressed: () => Get.offNamed('/auth/login'),
                child: MyText.bodyMedium("Back to login", fontWeight: 600))
          ],
        ),
      ),
    );
  }

  Widget buildField() {
    return Form(
      key: basicValidator.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("Enter Email", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            validator: basicValidator.getValidation('email'),
            controller: basicValidator.getController('email'),
            hintText: "Email",
          ),
        ],
      ),
    );
  }
}
