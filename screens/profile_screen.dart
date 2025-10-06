import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_repository.dart';

const Color logoRed = Color(0xFFA32020);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _contactCtrl;
  late String initials;
  late int colorValue;

  final List<Color> _colors = [
    Colors.red,
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    final p = ProfileRepository.instance.current;
    _nameCtrl = TextEditingController(text: p.name);
    _emailCtrl = TextEditingController(text: p.email);
    _contactCtrl = TextEditingController(text: p.contact);
    initials = p.initials;
    colorValue = p.colorValue;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ProfileRepository.instance.updateProfile(
      Profile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        contact: _contactCtrl.text.trim(), // contact saved
        initials: initials,
        colorValue: colorValue,
        avatarPath: '', // keep existing avatar logic or update later
      ),
    );
    Navigator.pop(context);
  }

  void _pickAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            children: [
              const ListTile(title: Text('Choose avatar color')),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => colorValue = c.value);
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(backgroundColor: c, radius: 26),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  initialValue: initials,
                  decoration: const InputDecoration(labelText: 'Initials (max 10 chars)'),
                  maxLength: 10, // allow up to 10 characters now
                  onChanged: (v) => initials = v.toUpperCase(),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: logoRed),
                  onPressed: () {
                    ProfileRepository.instance.updateAvatar(initials: initials, colorValue: colorValue);
                    Navigator.pop(ctx);
                    setState(() {}); // reflect change locally
                  },
                  child: const Text('Use this avatar', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 44,
      backgroundColor: Color(colorValue),
      child: Text(
        // show up to 10 characters (trim to fit)
        initials.length > 10 ? initials.substring(0, 10) : initials,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text('My Profile', style: TextStyle(color: logoRed, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: GestureDetector(onTap: _pickAvatar, child: avatar)),
              const SizedBox(height: 12),
              Center(child: TextButton(onPressed: _pickAvatar, child: const Text('Change Avatar'))),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                  if (!re.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Contact field added
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: logoRed),
                  onPressed: _save,
                  child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}