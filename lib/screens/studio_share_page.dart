import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/firebase/firebase_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:free_music/functions.dart';
import 'package:free_music/lists.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/size.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hive/hive.dart';
import 'package:http/http.dart';

class StudioSharePage extends StatefulWidget {
  final String path;
  const StudioSharePage({Key? key, required this.path}) : super(key: key);

  @override
  _StudioSharePageState createState() => _StudioSharePageState();
}

class _StudioSharePageState extends State<StudioSharePage> {
  TextEditingController tECSongName = TextEditingController();
  TextEditingController tECArtistName =
      TextEditingController(text: FirebaseAuthService().getUsername());

  int selectedLanguage = 0;
  int selectedMusicGenre = 0;

  bool info1 = false;
  bool isExplicit = false;
  bool isSharing = false;
  bool isShared = false;

  String textFieldText = "";

  double progressUploadAudio = 0.0;

  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void backToScreen() {
    if (isShared) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backToScreen();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text("Share"),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  backToScreen();
                },
                icon: Icon(Icons.arrow_back_ios_rounded))),
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            isShared
                ? Center(
                    child: Text(
                      "Your song is successfully published.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                : bodyColumn(context),
            isSharing
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progressUploadAudio,
                          color: Colors.red,
                        ),
                        Text(
                          "Your song is getting published. Please do not close the app!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 8,
                        )
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Padding bodyColumn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Song Name + Feats",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            TextField(
              autofocus: false,
              inputFormatters: [
                FilteringTextInputFormatter(
                    RegExp(
                        r"""^[\p{L}0-9 @,.<>#₺_&\-+()/*"':;!?~`|•√π÷×∆£€$¢^°={}%©®™√[\]]*$""",
                        caseSensitive: false, unicode: true, dotAll: true),
                    allow: true),
              ],
              controller: tECSongName,
              onChanged: (text) {},
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  hintText: "Song Name ft. Person Name",
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (info1 == false) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          info1 = true;
                        });
                        Future.delayed(const Duration(seconds: 5))
                            .then((value) {
                          setState(() {
                            info1 = false;
                          });
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(15),
                  filled: true,
                  fillColor: Colors.grey,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  )),
            ),
            info1
                ? Text(
                    "If there are other persons singing, you can add their names after song name just like giving example",
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold))
                : const SizedBox.shrink(),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 5,
            ),
            Text("Artist Name",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            TextField(
              controller: tECArtistName,
              enabled: false,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text("Language",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () async {
                await showGeneralDialogFunc(Lists().languages).then((value) {
                  setState(() {
                    selectedLanguage = value;
                  });
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: SizeConfig.safeBlockVertical! * 7.5,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Lists().languagesGetter(selectedLanguage),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 5,
            ),
            Text("Music Genre",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () async {
                await showGeneralDialogFunc(Lists().musicGenres).then((value) {
                  setState(() {
                    selectedMusicGenre = value;
                  });
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: SizeConfig.safeBlockVertical! * 7.5,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Lists().musicGenresGetter(selectedMusicGenre),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 2,
            ),
            Row(
              children: [
                Checkbox(
                  value: isExplicit,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  activeColor: fourthColor,
                  fillColor: MaterialStateProperty.all(fourthColor),
                  focusColor: fourthColor,
                  hoverColor: fourthColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isExplicit = value!;
                    });
                  },
                ),
                Text(
                  "Explicit Content",
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
            Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => funcShare(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(backgroundColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: fourthColor)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9.0, vertical: 12),
                    child: Text(
                      'Share',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: fourthColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void funcShare() async {
    FocusScope.of(context).unfocus();
    bool isReadyToShare = false;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: thirdColor,
          title: const Text(
            "Sure To Share?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "${tECSongName.text}\n${tECArtistName.text}\n${Lists().languagesGetter(selectedLanguage)}\n${Lists().musicGenresGetter(selectedMusicGenre)}\nExplicit = $isExplicit",
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Functions().checkInternetConnection().then((value) {
                  if (value) {
                    isReadyToShare = true;
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    // Functions().showToast(
                    //     "No internet connection!", ToastGravity.BOTTOM);
                  }
                });
              },
              style:
                  ElevatedButton.styleFrom(primary: fourthColor, elevation: 0),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: fourthColor), elevation: 0),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
    if (isReadyToShare) {
      setState(() {
        isSharing = true;
      });

      try {
        DateTime day = DateTime(3000, 04, 04, 23, 59, 59);
        await Functions().getCurrentGlobalTime(context).then((currentTime) {
          String songIdd =
              "${day.difference(currentTime).toString()}|${FirebaseAuthService().getUsername()}";

          Song song = Song(
              songName: tECSongName.text.trim(),
              artistName: FirebaseAuthService().getUsername(),
              language: Lists().languagesGetter(selectedLanguage),
              genre: Lists().musicGenresGetter(selectedMusicGenre),
              songId: songIdd,
              date: currentTime.toIso8601String(),
              isExplicit: isExplicit,
              views: 0,
              pathToSong:
                  'songs/${Lists().musicGenresGetter(selectedMusicGenre)}/${Lists().languagesGetter(selectedLanguage)}/$songIdd',
              songUrl: "",
              songNameForDB:
                  tECSongName.text.trim().replaceAll(" ", "").toLowerCase());

          File file = File(widget.path);

          Stream<firebase_storage.TaskSnapshot> stream = firebase_storage
              .FirebaseStorage.instance
              .ref(song.pathToSong)
              .putFile(file)
              .snapshotEvents;

          stream.listen((event) {
            setState(() {
              progressUploadAudio =
                  (((100.0 * event.bytesTransferred) / event.totalBytes)
                          .roundToDouble() /
                      100);
            });
            if (event.state == firebase_storage.TaskState.success) {
              FirebaseFirestoreService().setSongDatas(song).then((value) {
                song.songUrl = value;
                FirebaseFirestoreService().putOwnSong(song);
                setState(() {
                  isShared = true;
                  isSharing = false;
                });
              });
            }
          });
        });
      } on firebase_core.FirebaseException catch (e) {
        print(e.code);
        setState(() {
          isSharing = false;
          progressUploadAudio = 0.0;
        });
        if (e.code == 'permission-denied') {
          showDialog(
            barrierColor: thirdColor,
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "title",
                  style: TextStyle(color: Colors.white),
                ),
                content: Text("Content"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Future<String> getCurrentGlobalTime() async {
    Response response = await get(
        Uri.parse("http://worldtimeapi.org/api/timezone/Europe/Istanbul"));
    Map worldData = jsonDecode(response.body);
    return worldData['datetime'];
  }

  List<Widget> getChildrenForListWheel(list) {
    List<Widget> listForWiget = [];
    for (var item in list) {
      listForWiget.add(Center(
        child: Text(
          item,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ));
    }
    return listForWiget;
  }

  Future<int> showGeneralDialogFunc(List list) async {
    FocusScope.of(context).unfocus();
    int val = 0;
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              margin: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              height: SizeConfig.safeBlockVertical! * 30,
              decoration: const BoxDecoration(
                  color: thirdColor,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: SizeConfig.safeBlockVertical! * 4,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey))),
                  ),
                  ListWheelScrollView(
                    itemExtent: SizeConfig.safeBlockVertical! * 5,
                    onSelectedItemChanged: (selectedItem) {
                      val = selectedItem;
                    },
                    perspective: 0.005,
                    children: getChildrenForListWheel(list),
                    physics: const FixedExtentScrollPhysics(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.grey, elevation: 0),
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
    return val;
  }
}
