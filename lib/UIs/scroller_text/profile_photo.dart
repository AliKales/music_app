
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/size.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    Key? key,
    required this.context,required this.size, 
  }) : super(key: key);

  final BuildContext context;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:size,
      width: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.blueGrey[500], shape: BoxShape.circle),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          FirebaseAuthService().getEmail()[0].toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}