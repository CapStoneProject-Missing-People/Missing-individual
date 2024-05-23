// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3/components/my_button.dart';
import 'package:flutter3/components/my_textfield.dart';
import 'package:flutter3/pages/login_page.dart';
import 'package:flutter3/services/auth_services.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();

  final nameController = TextEditingController();

  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthService authService = AuthService();

  void signUpUser() {
    authService.signUpUser(
        context: context,
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        phoneNo: phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Icon(Icons.lock, size: 100),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(color: Colors.grey[700], fontSize: 24),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              //username textfield
              MyTextField(
                controller: nameController,
                hintText: 'Name',
              ),
              SizedBox(
                height: 15,
              ),

              MyTextField(
                controller: emailController,
                hintText: 'Email',
              ),

              SizedBox(
                height: 15,
              ),
              MyTextField(
                controller: phoneController,
                hintText: 'Phone No',
              ),

              SizedBox(
                height: 15,
              ),

              //password textfield
              PasswordField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(
                height: 10,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style:
                          TextStyle(color: Colors.blue.shade600, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              MyButton(
                buttonText: 'Sign Up',
                onTap: signUpUser,
              ),

              SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: TextStyle(fontSize: 15)),
                  SizedBox(width: 5),
                  GestureDetector(
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
