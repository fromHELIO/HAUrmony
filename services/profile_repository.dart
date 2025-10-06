import 'package:flutter/foundation.dart';
import '../models/profile.dart';

class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  final ValueNotifier<Profile> profileNotifier = ValueNotifier<Profile>(
    Profile(
      name: 'ADMIN',
      email: 'usc@hau.edu.ph',
      contact: '', // default empty contact
      initials: 'AD',
      colorValue: 0xFFD32F2F, // default red-ish
      avatarPath: '', // default no photo
    ),
  );

  Profile get current => profileNotifier.value;

  void updateName(String name) {
    final p = profileNotifier.value;
    final initials = _computeInitials(name);
    profileNotifier.value = Profile(
      name: name,
      email: p.email,
      contact: p.contact,
      initials: initials,
      colorValue: p.colorValue,
      avatarPath: p.avatarPath,
    );
  }

  void updateEmail(String email) {
    final p = profileNotifier.value;
    profileNotifier.value = Profile(
      name: p.name,
      email: email,
      contact: p.contact,
      initials: p.initials,
      colorValue: p.colorValue,
      avatarPath: p.avatarPath,
    );
  }

  void updateContact(String contact) {
    final p = profileNotifier.value;
    profileNotifier.value = Profile(
      name: p.name,
      email: p.email,
      contact: contact,
      initials: p.initials,
      colorValue: p.colorValue,
      avatarPath: p.avatarPath,
    );
  }

  void updateAvatar({required String initials, required int colorValue, String avatarPath = ''}) {
    final p = profileNotifier.value;
    profileNotifier.value = Profile(
      name: p.name,
      email: p.email,
      contact: p.contact,
      initials: initials,
      colorValue: colorValue,
      avatarPath: avatarPath,
    );
  }

  void updateProfile(Profile p) => profileNotifier.value = p;

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}