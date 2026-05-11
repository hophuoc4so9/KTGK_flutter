import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/auth_services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(children: [
            SizedBox(height: 90),

            Text("Sign Up"),

            SizedBox(height: 10),

            // EMAIL
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Email cannot be empty" : null,
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("email"),
                ),
              ),
            ),

            SizedBox(height: 10),

            // PASSWORD
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                validator: (value) => value!.length < 8
                    ? "Password should have at least 8 characters"
                    : null,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Password"),
                ),
              ),
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 65,
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    AuthServices()
                        .createAccountWithEmail(
                            _emailController.text,
                            _passwordController.text)
                        .then((result) {
                      if (result == "Account created") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Account created")),
                        );

                        Navigator.pushReplacementNamed(context, "/home");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }
                    });
                  }
                },
                child: Text("Sign Up", style: TextStyle(fontSize: 16)),
              ),
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 65,
              width: MediaQuery.of(context).size.width * .9,
              child: OutlinedButton(
                onPressed: () {
                  AuthServices().continueWithGoogle().then((result) {
                    if (result == "Login successful") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Signup successful")),
                      );

                      Navigator.pushReplacementNamed(context, "/home");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    }
                  }).catchError((e) {
                    print("Error $e");
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/gg.png",
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Continue with Google",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  child: Text("Login"),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}