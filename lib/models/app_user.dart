class AppUser {
  final String name;
  final String email;
  final String passwordHash;

  const AppUser({
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        name: m['name'] as String,
        email: m['email'] as String,
        passwordHash: m['passwordHash'] as String,
      );
}
