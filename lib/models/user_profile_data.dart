class UserProfile {
  final String name;
  final String email;
  final String profilePictureUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });
}

Future<UserProfile> fetchUserProfile(String userId) async {
  // Simulated data for demonstration
  var name = 'John Doe';
  var email = 'john.doe@example.com';
  var profilePictureUrl = 'https://example.com/profile.jpg';

  // Simulate network delay
  await Future.delayed(Duration(seconds: 2));

  return UserProfile(
    name: name,
    email: email,
    profilePictureUrl: profilePictureUrl,
  );
}
