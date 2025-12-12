import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Register",
              style: TextStyle(
                fontSize: 40,
                color: Color.fromARGB(255, 17, 46, 86),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

//note: lỗi route login screen
