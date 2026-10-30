import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> register() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text;

  setState(() {
    errorMessage = null;
  });

  // Local validation
  if (name.isEmpty) {
    setState(() {
      errorMessage = 'Please enter your name.';
    });
    return;
  }

  if (email.isEmpty) {
    setState(() {
      errorMessage = 'Please enter your email address.';
    });
    return;
  }

  if (password.isEmpty) {
    setState(() {
      errorMessage = 'Please enter a password.';
    });
    return;
  }

  if (password.length < 6) {
    setState(() {
      errorMessage = 'Password must be at least 6 characters.';
    });
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await FirebaseDatabase.instance
          .ref('users/${user.uid}')
          .set({
        'name': name,
        'email': email,
      });

      await user.updateDisplayName(name);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;

      case 'email-already-in-use':
        message = 'An account with this email already exists.';
        break;

      case 'weak-password':
        message = 'Your password is too weak. Please use a stronger password.';
        break;

      case 'network-request-failed':
        message =
            'Unable to connect. Please check your internet connection.';
        break;

      case 'operation-not-allowed':
        message =
            'Email and password registration is currently unavailable.';
        break;

      default:
        message = 'Registration failed. Please check your details and try again.';
    }

    if (mounted) {
      setState(() {
        errorMessage = message;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        errorMessage =
            'Something went wrong. Please try again.';
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Create your ReadLog account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 16),

                if (errorMessage != null)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ],
    ),
  ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}