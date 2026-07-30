import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final MyFormValidator basicValidator = MyFormValidator();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    basicValidator.addField('email',
        required: true,
        label: "Email",
        validators: [MyEmailValidator()],
        controller: TextEditingController());

    basicValidator.addField('password',
        required: true,
        label: "Password",
        validators: [MyLengthValidator(min: 6, max: 10)],
        controller: TextEditingController());
  }

  @override
  void dispose() {
    basicValidator.getController('email')?.dispose();
    basicValidator.getController('password')?.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      ref.read(loginLoadingProvider.notifier).state = true;
      final email = basicValidator.getController('email')?.text ?? "";
      final password = basicValidator.getController('password')?.text ?? "";
      
      final success = await ref.read(loginActionProvider.notifier).login(email, password);
      ref.read(loginLoadingProvider.notifier).state = false;

      if (success) {
        Utils.showSuccessToast("Login successful!", context: context);
        String nextUrl =
            Uri.parse(ModalRoute.of(context)?.settings.name ?? "")
                    .queryParameters['next'] ??
                "/dashboard/analytics";
        Get.toNamed(nextUrl);
      } else {
        Utils.showErrorToast("Login Failed: Invalid email or password", context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final obscureText = ref.watch(loginObscureTextProvider);
    final isCheckToggle = ref.watch(loginRememberMeProvider);
    final isLoading = ref.watch(loginLoadingProvider);

    return AuthLayout(
      child: Padding(
        padding: MySpacing.x(MediaQuery.of(context).size.width * .03),
        child: Column(
          children: [
            MyContainer(
                height: 40,
                paddingAll: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(Images.logo, fit: BoxFit.cover, width: 175)),
            MySpacing.height(44),
            MyText.titleLarge("Welcome Back !", fontWeight: 600),
            MySpacing.height(12),
            MyText.bodyMedium("Enter your Email and Password to continue",
                fontWeight: 600),
            MySpacing.height(24),
            buildFields(obscureText),
            Row(
              children: [
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.transparent),
                  child: Checkbox(
                    activeColor: contentTheme.primary,
                    value: isCheckToggle,
                    onChanged: (value) => ref.read(loginRememberMeProvider.notifier).state = value ?? false,
                    visualDensity: getCompactDensity,
                  ),
                ),
                MySpacing.width(12),
                MyText.bodyMedium("Remember Me", fontWeight: 600),
                const Spacer(),
                MyButton.text(
                    onPressed: () => Get.toNamed('/auth/forgot_password'),
                    child: MyText.bodyMedium("Forgot Password?", fontWeight: 600))
              ],
            ),
            MySpacing.height(24),
            MyButton.block(
                elevation: 0,
                borderRadiusAll: 8,
                padding: MySpacing.y(20),
                backgroundColor: contentTheme.primary,
                onPressed: isLoading ? null : onLogin,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: contentTheme.onPrimary))
                    : MyText.bodyMedium(
                        "Login",
                        fontWeight: 600,
                        color: contentTheme.onPrimary,
                      )),
            MySpacing.height(24),
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
          MyText.bodyMedium("Enter Email", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: basicValidator.getController('email'),
            validator: basicValidator.getValidation('email'),
            hintText: "Email",
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
          MySpacing.height(20),
          MyText.bodyMedium("Enter Password", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: basicValidator.getController('password'),
            validator: basicValidator.getValidation('password'),
            hintText: "Password",
            obscureText: obscureText,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onLogin(),
            suffixIcon: InkWell(
              onTap: () => ref.read(loginObscureTextProvider.notifier).state = !obscureText,
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
