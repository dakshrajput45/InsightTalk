import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/helper/toast.dart';
import 'package:insighttalk_frontend/router.dart'; // Assuming routeNames is defined here
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key}); // Corrected super.key

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('userDetails');
  final bool _isNotValidate = false;
  bool _loggin = false, _logginGoogle = false;

  void handleSignUp(int val) {
    updateLoginStatus(val);
  }

  bool _isHidden = true;

  // handleLogin(String email, String password) {
  //   final user = _itUserAuthSDK.emailandPasswordLogIn(email, password);
  //   return user;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 120),
            child: const Text(
              'Login To Insight Talk',
              style: TextStyle(
                color: Colors.black,
                fontSize: 33,
                fontWeight: FontWeight.w700,
              ),
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
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _loggin = true;
                        });
                        User? user = await _itUserAuthSDK.emailandPasswordLogIn(
                            email: emailController.text.trim(),
                            password: passwordController.text);
                        if (user != null && mounted) {
                          DsdToastMessages.success(context,
                              text: "Email Login Successful");
                          handleSignUp(2);
                          context.goNamed(routeNames.experts);
                        } else {
                          print("Login Failed");
                        }
                        setState(() {
                          _loggin = false;
                        });
                        // Navigate to experts route
                      },
                      child: _loggin
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Log In'),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
                  SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Google Log In Function Added here (Same function used for Sign Up)
                        setState(() {
                          _logginGoogle = true;
                        });
                        User? user = await _itUserAuthSDK.googleSignUp();
                        print('Google Log In function is called $mounted');
                        if (user != null && mounted) {
                          final DocumentSnapshot userDoc =
                              await usersCollection.doc(user.uid).get();
                          handleSignUp(2);
                          if (!userDoc.exists) {
                            context.goNamed(routeNames.editprofileview);
                          } else {
                            DsdToastMessages.success(context,
                                text: "Google Login Successful");
                            await Future.delayed(const Duration(seconds: 2));
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
                      label:  _logginGoogle
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                        'Log in with Google',
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
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          handleSignUp(3);
                          context.pushNamed(
                              routeNames.signup); // Navigate to signup route
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add your Forgot Password logic here
                          print(_itUserAuthSDK.getUser());
                        },
                        onLongPress: () {
                          _itUserAuthSDK.signOut();
                        },
                        child: const Text(
                          "Forget Password",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
