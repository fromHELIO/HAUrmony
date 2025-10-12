class Profile {
  String name;
  String email;
  String contact; // new contact field
  String initials;
  int colorValue;
  String avatarPath; // local file path for uploaded picture (empty = none)

  Profile({
    required this.name,
    required this.email,
    required this.contact,
    required this.initials,
    required this.colorValue,
    required this.avatarPath,
  });
}