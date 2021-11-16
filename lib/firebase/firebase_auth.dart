

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  String getUsername(){
    return FirebaseAuth.instance.currentUser?.email!.replaceAll("@caroby.com", "")??"ozel_admin_code:002";
  }
  String getEmail(){
    return FirebaseAuth.instance.currentUser?.email??"";
  }
}