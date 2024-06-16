import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String profilePic;
  final String gender;

  const ProfileAvatar({
    required this.profilePic,
    required this.gender,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 27,
          backgroundColor: Colors.transparent,
          backgroundImage: profilePic.isEmpty
              ? (gender == "Male"
              ? Image.asset("lib/images/profile_pic.png").image
              : Image.asset("lib/images/profile_pic_female.png").image)
              : NetworkImage(profilePic),
        ),
      ),
    );
  }
}
