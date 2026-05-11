import 'package:flutter/material.dart';
import 'package:hotuanphuoc_2224802010872_lab4/common/common.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthServices()
        .loginWithEmail(_emailController.text, _passwordController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == "Login successful") {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.errorRed,
      ));
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final result = await AuthServices().continueWithGoogle().catchError((e) {
      return e.toString();
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == "Login successful") {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.errorRed,
      ));
    }
  }

  Widget _orDivider() {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey.shade300)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("OR",
            style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
      ),
      Expanded(child: Divider(color: Colors.grey.shade300)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.authBackgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    const Icon(Icons.chat_bubble_rounded,
                        size: 56, color: Colors.white),
                    const SizedBox(height: 20),
                    Text("Welcome Back", style: AppTheme.headingLarge),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to continue",
                      style: AppTheme.caption.copyWith(
                          color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White bottom card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Login", style: AppTheme.headingMedium),
                      const SizedBox(height: 28),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? "Email cannot be empty" : null,
                        decoration: AppTheme.inputDecoration(
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (v) => v!.length < 8
                            ? "Password must be at least 8 characters"
                            : null,
                        decoration: AppTheme.inputDecoration(
                          label: "Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Login button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Login"),
                      ),
                      const SizedBox(height: 20),

                      _orDivider(),
                      const SizedBox(height: 20),

                      // Google sign-in
                      OutlinedButton(
                        onPressed: _isLoading ? null : _googleSignIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/gg.png",
                                height: 22, width: 22),
                            const SizedBox(width: 10),
                            const Text("Continue with Google"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: AppTheme.caption
                                  .copyWith(color: Colors.grey.shade600)),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, "/signup"),
                            child: const Text("Sign up",
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
