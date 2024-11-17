import 'package:fcm/controllers/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sign Up",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Email"),
                hintText: "Enter your Email"),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Password"),
                hintText: "Enter your Password"),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
                onPressed: () async {
                  await AuthService.createAccountWithEmail(
                          emailController.text, passwordController.text)
                      .then((value) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(value)));
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  });
                },
                child: Text("Submit")),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Already Signed Up"),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, '/');
                  },
                  child: Text("Login"))
            ],
          )
        ],
      ),
    )));
  }
}
