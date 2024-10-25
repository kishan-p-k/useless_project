// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// class LoginPage extends StatelessWidget {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   LoginPage({super.key});

//   void _login(BuildContext context) async {
//     String phone = phoneController.text;
//     String password = passwordController.text;

//     if (phone.isEmpty || password.isEmpty) {
//       // Show an error if inputs are invalid
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Error"),
//           content: const Text("Please enter both phone number and password."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     try {
//       // Log in using Firebase Authentication
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: phone, // Use email as the phone number for this example
//         password: password,
//       );

//       // Navigate to home page or show success message
//       print('User logged in: ${userCredential.user!.uid}');
//       // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
//     } catch (e) {
//       // Handle login error
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Login Failed"),
//           content: Text(e.toString()),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//       print('Login error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/th.jpg'), // Background image
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   border: const OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16.0),
//               TextField(
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: const OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () => _login(context),
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
//                 ),
//                 child: const Text('Login'),
//               ),
//               const SizedBox(height: 16.0),
//               TextButton(
//                 onPressed: () {
//                   // Navigate to signup page
//                   print('Navigate to signup page');
//                   // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
//                 },
//                 child: const Text('Don\'t have an account? Sign up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
