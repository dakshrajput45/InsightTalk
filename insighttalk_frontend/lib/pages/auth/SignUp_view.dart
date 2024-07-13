import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
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
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Sign Up Button
                          var confirmPassword = confirmPasswordController.text;
                          var password = passwordController.text;
                          if (password == confirmPassword) {
                            var email = emailController.text;
                            if (await _itUserAuthSDK.emailandPasswordSignUp(
                                    email, password) !=
                                null) {
                              context.pushNamed(routeNames.profilescreen);
                            }
                          }
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
                          // Add your Google SignUp logic here
                          if (await _itUserAuthSDK.googleSignUp() != null) {
                            context.goNamed(routeNames.profilescreen);
                          }
                          // Needs to implement Signout Button to Signout of App
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
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.grey),
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
