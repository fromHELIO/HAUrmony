// import 'package:flutter/material.dart';
// import '../models/profile.dart';
// import '../services/profile_repository.dart';

// const Color logoRed = Color(0xFFA32020);

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameCtrl;
//   late TextEditingController _emailCtrl;
//   late TextEditingController _contactCtrl;
//   late String initials;
//   late int colorValue;

//   @override
//   void initState() {
//     super.initState();
//     final p = ProfileRepository.instance.current;
//     _nameCtrl = TextEditingController(text: p.name);
//     _emailCtrl = TextEditingController(text: p.email);
//     _contactCtrl = TextEditingController(text: p.contact);
//     initials = p.initials;
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _contactCtrl.dispose();
//     super.dispose();
//   }

//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//     ProfileRepository.instance.updateProfile(
//       Profile(
//         name: _nameCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         contact: _contactCtrl.text.trim(), // contact saved
//         initials: initials,
//       ),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//         title: const Text('My Profile', style: TextStyle(color: logoRed, fontWeight: FontWeight.bold)),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                TextFormField(
//                   controller: _nameCtrl,
//                   decoration: const InputDecoration(labelText: 'Full Name'),
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _emailCtrl,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) return 'Enter email';
//                     final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
//                     if (!re.hasMatch(v.trim())) return 'Enter a valid email';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 // Contact field added
//                 TextFormField(
//                   controller: _contactCtrl,
//                   decoration: const InputDecoration(labelText: 'Contact Number'),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 18),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: logoRed),
//                     onPressed: _save,
//                     child: const Text('SAVE', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }