import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/helper/toast.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final bool _isNotValidate = false;
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('userDetails');
  bool _loggin = false, _logginGoogle = false;

  bool _isHidden = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                top: MediaQuery.of(context).size.height * 0.25,
                right: 35,
                left: 35,
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isHidden
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      hintText: 'Confirm Password',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _loggin = true;
                        });
                        if (passwordController.text ==
                            confirmPasswordController.text) {
                          User? user =
                              await _itUserAuthSDK.emailandPasswordSignUp(
                                  email: emailController.text.trim(),
                                  password: passwordController.text);
                          if (user != null && mounted) {
                            final DocumentSnapshot userDoc =
                                await usersCollection.doc(user.uid).get();
                            if (!userDoc.exists) {
                              context.goNamed(routeNames.editprofileview);
                            } else {
                              DsdToastMessages.error(context,
                                  text:
                                      "User with this email already exist (Try Sign In)");
                              // context.goNamed(routeNames.signup);
                            }
                          } else {
                            print("Sign Up Failed");
                          }
                        } else {
                          print("Password and Confirm Passwords are not same");
                        }
                        setState(() {
                          _loggin = false;
                        });
                        // const ProfileScreen();
                      },
                      child: _loggin
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign Up'),
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
                    width: 100,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Google Sign Up Function Added here (Same function used for Log In)
                        setState(() {
                          _logginGoogle = true;
                        });
                        User? user = await _itUserAuthSDK.googleSignUp();
                        if (user != null && mounted) {
                          final DocumentSnapshot userDoc =
                              await usersCollection.doc(user.uid).get();
                          if (!userDoc.exists) {
                            context.goNamed(routeNames.editprofileview);
                          } else {
                            context.goNamed(routeNames.experts);
                          }
                        } else {
                          print("Google Login Failed");
                        }
                        setState(() {
                          _logginGoogle = false;
                        });
                        // Navigate to experts route
                      },
                      icon: _logginGoogle
                          ? const SizedBox.shrink()
                          : Image.asset(
                              'assets/images/search.png',
                              height: 24.0,
                              width: 24.0,
                            ),
                      label: _logginGoogle
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Sign Up with Google',
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
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
    );
  }
}
