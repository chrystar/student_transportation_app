import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_transportation_app/models/user_model.dart';
import 'package:student_transportation_app/routes/app_routes.dart';
import 'package:student_transportation_app/views/auth/forgot_password_screen.dart';
import 'package:student_transportation_app/views/parent/parent_home_screen.dart';
import '../../providers/auth_provider.dart';
import '../widgets/button.dart';
import '../widgets/text_widget.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      print('Attempting to sign in...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('Sign in successful');

      final userId = authProvider.user!.uid;
      print('User ID: $userId');
      final role = await authProvider.getUserRole(userId);
      print('User role: $role');

      if (!mounted) return;

      switch (role) {
        case 'parent':
          print('Navigating to parent home screen');
          Navigator.of(context).pushReplacementNamed(AppRoutes.parentHome);
          break;
        case 'driver':
          print('Navigating to driver home screen');
          Navigator.of(context).pushReplacementNamed(AppRoutes.driverHome);
          break;
        case 'student':
          print('Navigating to student home screen');
          Navigator.of(context).pushReplacementNamed(AppRoutes.studentHome);
          break;
        default:
          print('Unknown role: $role');
          // Handle other roles or show an error
          return;
      }
    } catch (e) {
      print('Error during login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      text24Normal(
                        text: "Login",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 12),
                      text14Normal(
                        text: 'Welcome back to the app',
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                      },
                      child: text12Normal(
                        text: "Forgot Password?",
                        color: Color(0xffEC441E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,

                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: Color(0xff4B5768),
                        height: 0.5,
                        width: 125,
                      ),
                      text14Normal(
                          text: 'Or sign in',
                          color: Color(0xff999DA3)),
                      Container(
                        color: Color(0xff4B5768),
                        height: 0.5,
                        width: 125,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Button(
                    onPressed: (){},
                    text: "Continue with Google",
                    width: double.maxFinite,
                    color: Color(0xffE4E7EB),
                    textColor: Colors.black,
                    //borderColor: AppColor.primaryThreeElementText,
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    child: text16Normal(
                      text: 'Create an Account',
                      color: Color(0xffEC441E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
