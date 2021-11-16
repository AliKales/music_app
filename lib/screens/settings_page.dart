import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:free_music/UIs/scroller_text/profile_photo.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/screens/main_page.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  final bool? isFirstPage;
  const SettingsPage({Key? key, this.isFirstPage}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController textEditingControllerUserName = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();

  bool isPasswordNotShown = true;
  bool isProgress = false;
  bool progress2 = false;
  bool? isSignIn;

  final englishCharacters = RegExp(r'^[a-zA-Z0-9_.\-=]+$');

  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => listenUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          leading: Visibility(
            visible: widget.isFirstPage != true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.white),
              onPressed: () {
                if (isSignIn!) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          title: Text(
            "Settings",
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: body());
  }

  //WIDGETS----------------------------------

  dynamic body() {
    if (isSignIn == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
        ),
      );
    } else if (isSignIn == false) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kullanıcı Adı",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            TextField(
              controller: textEditingControllerUserName,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(15),
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 5,
            ),
            Text("Parola",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            TextField(
              obscureText: isPasswordNotShown,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              controller: textEditingControllerPassword,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordNotShown = !isPasswordNotShown;
                      });
                    },
                    icon: !isPasswordNotShown
                        ? const Icon(Icons.remove_red_eye, color: Colors.white)
                        : const Icon(Icons.remove_red_eye_outlined,
                            color: Colors.white),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(15),
                  filled: true,
                  fillColor: Colors.grey,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  )),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 5,
            ),
            Align(
              alignment: Alignment.center,
              child: isProgress
                  ? const CircularProgressIndicator(
                      color: Colors.white70,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (checkUserNameAndPassword() == "") {
                          setState(() {
                            isProgress = true;
                          });
                          await signIn().then((value) {
                            if (widget.isFirstPage == true) {
                              Route route = MaterialPageRoute(
                                  builder: (context) => const MainPage());
                              Navigator.pushReplacement(context, route);
                            } else {
                              setState(() {
                                isProgress = false;
                              });
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(checkUserNameAndPassword())));
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white70),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 12),
                        child: Text(
                          'Oturum aç',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 5,
            ),
            Align(
              alignment: Alignment.center,
              child: isProgress
                  ? const CircularProgressIndicator(
                      color: Colors.white70,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (checkUserNameAndPassword() == "") {
                          setState(() {
                            isProgress = true;
                          });
                          await signUp().then((value) {
                            setState(() {
                              isProgress = false;
                            });
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(checkUserNameAndPassword())));
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(backgroundColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: Colors.white70)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 12),
                        child: Text(
                          'Hesap Oluştur',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              ProfilePhoto(
                context: context,
                size: SizeConfig.safeBlockHorizontal! * 20,
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 2,
              ),
              Text(
                user!.email!.replaceAll("@caroby.com", ""),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 6,
              ),
              progress2
                  ? Column(
                      children: [
                        Text(
                          "If you sign out, you lose all your playlists. Are you sure?",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 6,
                        ),
                        elevatedButton("Yes", () async {
                          setState(() {
                            isProgress = true;
                          });
                          await FirebaseAuth.instance.signOut().then((value) {
                            textEditingControllerPassword.clear();
                            textEditingControllerUserName.clear();
                            box.delete("ownSongs");
                            box.delete("playlists");
                            setState(() {
                              isProgress = false;
                            });
                          });
                        }, true),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 3,
                        ),
                        elevatedButton("Back", () async {
                          setState(() {
                            progress2 = false;
                          });
                        }, false)
                      ],
                    )
                  : isProgress
                      ? const CircularProgressIndicator(
                          color: Colors.white70,
                        )
                      : elevatedButton("Sign Out", () {
                          setState(() {
                            progress2 = true;
                          });
                        }, true),
            ],
          ),
        ),
      );
    }
  }

  ElevatedButton elevatedButton(
      String text, Function() function, bool isFilled) {
    return ElevatedButton(
      onPressed: function,
      style: ButtonStyle(
        backgroundColor: isFilled
            ? MaterialStateProperty.all(Colors.white70)
            : MaterialStateProperty.all(backgroundColor),
        shape: isFilled
            ? MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ))
            : MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.white70)),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 12),
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color: isFilled ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //FUNCTIONS--------------------------------

  void listenUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? userr) {
      if (userr == null) {
        setState(() {
          isSignIn = false;
        });
      } else {
        user = userr;
        setState(() {
          isSignIn = true;
        });
      }
    });
  }

  String checkUserNameAndPassword() {
    if (textEditingControllerUserName.text.isEmpty ||
        textEditingControllerPassword.text.isEmpty) {
      return "User Name and Password can not be empty!";
    } else if (!englishCharacters
            .hasMatch(textEditingControllerUserName.text) ||
        !englishCharacters.hasMatch(textEditingControllerPassword.text)) {
      return 'User Name and Password only English characters, (-) (_) (.) and no WhiteSpace';
    } else {
      textEditingControllerUserName.text.trim();
      textEditingControllerPassword.text.trim();
      return "";
    }
  }

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${textEditingControllerUserName.text}@caroby.com",
          password: textEditingControllerPassword.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar('Wrong password provided for that user.');
      }
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  Future signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "${textEditingControllerUserName.text}@caroby.com",
              password: textEditingControllerPassword.text)
          .then((value) {
        Route route = MaterialPageRoute(builder: (context) => const MainPage());
        Navigator.pushReplacement(context, route);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar("The password provided is too weak!");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar("The account already exists for that email!");
      }
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  void showSnackBar(String text) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
