import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/api_functions/auth/auth_user.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_view.dart';
import 'package:insighttalk_frontend/router.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isNotValidate = false;
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 100),
              child: const Text(
                'SignUp To Insight Talk',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 33,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.20,
                  right: 35,
                  left: 35,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        hintText: 'Password',
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        hintText: 'Confirm Password',
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double
                          .infinity, // Makes the button take the full width of its parent
                      child: ElevatedButton(
                        onPressed: () async {
                          if (passwordController.text ==
                              confirmPasswordController.text) {
                            User? user =
                                await _itUserAuthSDK.emailandPasswordSignUp(
                                    email: emailController.text,
                                    password: passwordController.text);
                            if (user != null && mounted) {
                              context.pushNamed(routeNames.profilescreen);
                              // context.goNamed(routeNames.experts);
                            } else {
                              print("Sign Up Failed");
                            }
                          } else {
                            print(
                                "Password and Confirm Passwords are not same");
                          }
                          // const ProfileScreen();
                        },
                        child: const Text("Sign Up"),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "OR",
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
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Google Sign Up Function Added here (Same function used for Log In)
                          User? user = await _itUserAuthSDK.googleSignUp();
                          if (user != null && mounted) {
                            context.pushNamed(routeNames.profilescreen);
                            // const ProfileScreen();
                          } else {
                            print("Google Login Failed");
                          }
                          // Navigate to experts route
                        },
                        icon: Image.asset(
                          'assets/images/search.png',
                          height: 24.0,
                          width: 24.0,
                        ),
                        label: const Text(
                          'SignUp with Google',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
