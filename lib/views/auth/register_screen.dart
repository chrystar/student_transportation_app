import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_transportation_app/views/widgets/custom_textfield.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/button.dart';
import '../widgets/text_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _selectedRole,
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  appTextField(
                    controller: _nameController,
                    hintText: "Enter your full name",
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  appTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    validate: (value) {
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
                  DropdownButtonFormField<String>(
                    //value: _selectedRole,
                    decoration: InputDecoration(
                      //labelText: 'Role',
                      hintText: 'role',
                      prefixIcon: const Icon(Icons.work),
                      border: const OutlineInputBorder(),
                      filled: false,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Student'),
                      ),
                      DropdownMenuItem(
                        value: 'parent',
                        child: Text('Parent'),
                      ),
                      DropdownMenuItem(
                        value: 'driver',
                        child: Text('Driver'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  appTextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hintText: 'Enter Password',
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
                    validate: (value) {
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
                  appTextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    hintText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text12Normal(
                        text:
                        "By continuing, you agree to our",
                        color: AppColor.primaryThreeElementText,
                      ),
                      text12Normal(
                        text:
                        " terms & conditions",
                        color: Color(0xffEC441E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GestureDetector(
                          onTap: auth.isLoading ? null : _register,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xffEC441E),
                                borderRadius: BorderRadius.circular(15)),
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
                                  : Center(
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
                        width: 150,
                      ),
                      text14Normal(
                          text: 'Or',
                          color: Color(0xff999DA3)),
                      Container(
                        color: Color(0xff4B5768),
                        height: 0.5,
                        width: 150,
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
                  const SizedBox(height: 16),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          text14Normal(
                            text: 'Already have an account?',
                            color: Colors.grey,
                          ),
                          text14Normal(
                            text: ' Sign in here',
                            color: Color(0xffEC441E),
                          ),
                        ],
                      )
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
