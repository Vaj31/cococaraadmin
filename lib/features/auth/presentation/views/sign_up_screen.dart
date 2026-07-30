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
import 'package:ccpladmin/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
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
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'first_name',
      required: true,
      label: 'First Name',
      validators: [MyNameValidator(max: 10)],
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'last_name',
      required: true,
      label: 'Last Name',
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'password',
      required: true,
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(),
    );
  }

  @override
  void dispose() {
    basicValidator.getController('email')?.dispose();
    basicValidator.getController('first_name')?.dispose();
    basicValidator.getController('last_name')?.dispose();
    basicValidator.getController('password')?.dispose();
    super.dispose();
  }

  void onLogin() {
    if (basicValidator.validateForm()) {
      String nextUrl =
          Uri.parse(ModalRoute.of(context)?.settings.name ?? "")
                  .queryParameters['next'] ??
              "/dashboard/analytics";
      Get.toNamed(nextUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final obscureText = ref.watch(signUpObscureTextProvider);

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
            MyText.titleLarge("Create an Account", fontWeight: 600),
            MySpacing.height(12),
            MyText.bodyMedium(
                "Hello, We're glad you're here. Create your account below",
                fontWeight: 600),
            MySpacing.height(24),
            buildFields(obscureText),
            MySpacing.height(24),
            MyButton.block(
                elevation: 0,
                borderRadiusAll: 8,
                padding: MySpacing.y(20),
                backgroundColor: contentTheme.primary,
                onPressed: onLogin,
                child: MyText.bodyMedium(
                  "Register Account",
                  fontWeight: 600,
                  color: contentTheme.onPrimary,
                )),
            MySpacing.height(24),
            Row(
              children: [
                const Expanded(child: Divider()),
                MyContainer.roundBordered(
                    paddingAll: 0,
                    height: 30,
                    width: 30,
                    child: Center(
                        child: MyText.bodySmall("OR", fontWeight: 700))),
                const Expanded(child: Divider()),
              ],
            ),
            MySpacing.height(24),
            MyContainer.bordered(
              borderRadiusAll: 8,
              paddingAll: 0,
              height: 44,
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyContainer(
                    height: 20,
                    width: 20,
                    paddingAll: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Image.asset(Images.google, fit: BoxFit.cover),
                  ),
                  MySpacing.width(12),
                  MyText.bodyMedium("Sign up with Google", fontWeight: 600),
                ],
              ),
            ),
            MySpacing.height(24),
            InkWell(
                onTap: () => Get.toNamed('/auth/login'),
                child: MyText.bodyMedium(
                  "Already have an account?",
                  fontWeight: 600,
                ))
          ],
        ),
      ),
    );
  }

  Widget buildFields(bool obscureText) {
    return Form(
      key: basicValidator.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium("Enter First Name", fontWeight: 700),
                    MySpacing.height(8),
                    FlowKitTextField(
                      controller: basicValidator.getController('first_name'),
                      validator: basicValidator.getValidation('first_name'),
                      hintText: "First Name",
                    ),
                  ],
                ),
              ),
              MySpacing.width(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium("Enter Last Name", fontWeight: 700),
                    MySpacing.height(8),
                    FlowKitTextField(
                      controller: basicValidator.getController('last_name'),
                      validator: basicValidator.getValidation('last_name'),
                      hintText: "Last Name",
                    ),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(20),
          MyText.bodyMedium("Enter Email", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: basicValidator.getController('email'),
            validator: basicValidator.getValidation('email'),
            hintText: "Email",
          ),
          MySpacing.height(20),
          MyText.bodyMedium("Enter Password", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: basicValidator.getController('password'),
            validator: basicValidator.getValidation('password'),
            hintText: "Password",
            obscureText: obscureText,
            suffixIcon: InkWell(
              onTap: () => ref.read(signUpObscureTextProvider.notifier).state = !obscureText,
              child: Icon(
                  obscureText ? LucideIcons.eye_off : LucideIcons.eye,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
