import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/core/utils/vadilator.dart';
import 'package:oezbooking/features/home/presentation/page/home_page.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_event.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_state.dart';
import 'package:oezbooking/features/login/presentation/widgets/input_field.dart';
import 'package:oezbooking/features/login/presentation/widgets/main_button.dart';

class LoginPage extends StatefulWidget {
  static String routeName = "/LoginPage";

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();

  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _loginFormKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                ImageHelper.loadAssetImage(
                  'assets/images/ic_launcher.png',
                  height: 78,
                ),
                const SizedBox(height: 48.0),
                CustomInputField(
                  controller: _emailController,
                  label: "abc@email.com",
                  prefixIconName: "ic_email_outlined.png",
                  validator: Validator.validateEmail,
                ),
                const SizedBox(height: 18.0),
                CustomInputField(
                  controller: _passwordController,
                  obscureText: true,
                  label: "Your password",
                  prefixIconName: "ic_lock_outlined.png",
                  validator: Validator.validatePassword,
                ),
                const SizedBox(height: 8.0),
                const SizedBox(height: 28.0),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is LoginFailed) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        DialogUtils.hide(context);
                      });
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            state.error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is LoginSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        DialogUtils.hide(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),
                MainElevatedButton(
                  text: "LOGIN",
                  onTap: () => handleLogin(context),
                ),
                const SizedBox(height: 300.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  handleLogin(BuildContext context) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (_loginFormKey.currentState?.validate() ?? false) {
      DialogUtils.showLoadingDialog(context);
      loginBloc.add(PressedLogin(email, password));
    }
  }
}
