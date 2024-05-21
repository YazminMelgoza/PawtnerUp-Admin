import 'package:pawtnerup_admin/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtnerup_admin/config/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:pawtnerup_admin/utils/login_google_utils.dart';

// LoginScreen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/fondonaranja.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Icon Banner
                  IconButton(
                    icon: Image.asset(
                      'assets/images/image.png',
                      width: 220,
                      height: 170,
                    ),
                    onPressed: () => {},
                  ),
                  //const SizedBox(height: 5),
                  const Text('PawtnerUp',
                      style: TextStyle(
                          fontFamily: 'PottaOne',
                          color: Colors.white,
                          fontSize: 50,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              blurRadius: 20,
                              offset: Offset(4, 4),
                            )
                          ])),

                  const SizedBox(height: 15),

                  Container(
                    height: MediaQuery.of(context).size.height - 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: _LoginForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final username = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: AppColor.darkblue,
            ),
          ),

          const SizedBox(height: 20),

          //FORMS
          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            controller: username,
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            controller: password,
          ),

          const SizedBox(height: 30),

          //INGRESAR
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: 'Ingresar',
              buttonColor: AppColor.blue,
              onPressed: () async {
                try {
                  UserCredential? credentials = await LoginGoogleUtils()
                      .loginUserWithEmail(username.text, password.text);
                  if (credentials.user != null) {
                    if (context.mounted) {
                      String? userName =
                          credentials.user?.displayName ?? "Usuario";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Bienvenido, $userName!",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      );
                      context.go("/Root");
                    }
                  }
                } catch (e) {
                  debugPrint("$e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "El correo o contraseña es incorrecta. Inténtelo de nuevo.",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 25),

          // NO ACCOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿No tienes cuenta?'),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Regístrate'),
              ),
            ],
          ),
          //const Spacer(flex: 1),
        ],
      ),
    );
  }
}
