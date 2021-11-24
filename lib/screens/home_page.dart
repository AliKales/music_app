import 'package:flutter/material.dart';
import 'package:free_music/UIs/scroller_text/custom_appbar.dart';
import 'package:free_music/UIs/scroller_text/song_list_widget.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_firestore.dart';
import 'package:free_music/lists.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/screens/settings_page.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  final bool wifi;
  final Function(Song) onDataChange;
  final Function(Song) onDotsClicked;
  const HomePage(
      {Key? key,
      required this.onDataChange,
      required this.onDotsClicked,
      required this.wifi})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  List<Song> songsTaken = [];
  int selectedLanguage = 0;
  int selectedMusicGenre = 0;
  bool progressSearching = false;
  bool visibility1 = true;
  String lastSongId = "";

  var box = Hive.box('database');

  void goToSettingPage() async {
    Route route = MaterialPageRoute(builder: (_) {
      return const SettingsPage();
    });
    Navigator.push(context, route);
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (value) {
        value.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/backgrounds/Katman 0.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppbar(
                    text: greeting(),
                    padding: 0,
                    leftWidgets: const [],
                    rightWidgets: [
                      IconButton(
                        onPressed: () {
                          goToSettingPage();
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  widgetForSpace(5, 0),
                  Text(
                    "Recently Released",
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  widgetInfoFilter(
                      context, Lists().musicGenresGetter(selectedMusicGenre),
                      () async {
                    await showGeneralDialogFunc(Lists().musicGenres)
                        .then((value) {
                      if (selectedMusicGenre != value&&widget.wifi==true) {
                        setState(() {
                          selectedMusicGenre = value;
                                                    lastSongId="";
                          songsTaken = [];
                        });
                        if (selectedLanguage != 0 && selectedMusicGenre != 0) {
                          getSongs();
                        }
                      }
                    });
                  }),
                  widgetForSpace(2, 0),
                  widgetInfoFilter(
                      context, Lists().languagesGetter(selectedLanguage),
                      () async {
                    await showGeneralDialogFunc(Lists().languages)
                        .then((value) {
                      if (selectedLanguage != value&&widget.wifi==true) {
                        setState(() {
                          selectedLanguage = value;
                          lastSongId="";
                          songsTaken = [];
                        });
                        if (selectedLanguage != 0 && selectedMusicGenre != 0) {
                          getSongs();
                        }
                      }
                    });
                  }),
                  widgetForSpace(3, 0),
                  songsTaken.isEmpty
                      ? Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widgetForSpace(10, 0),
                              progressSearching
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Text(
                                      selectedLanguage == 0 ||
                                              selectedMusicGenre == 0
                                          ? "PLEASE PICK A GENRE & LANGUAGE"
                                          : "SORRY. THERE'RE NO SONG FOR THIS GENRE & LANGUAGE :/",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: songsTaken.length + 1,
                          itemBuilder: (_, index) {
                            if (index == songsTaken.length) {
                              return lastWidgets();
                            } else {
                              if (index < songsTaken.length - 1) {
                                return Column(
                                  children: [
                                    widgetSongLists(index),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Divider(
                                        color: Colors.white,
                                        height:
                                            SizeConfig.safeBlockVertical! * 0.5,
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return widgetSongLists(index);
                              }
                            }
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InkWell widgetSongLists(int index) {
    return InkWell(
        onTap: () {
          widget.onDataChange(songsTaken[index]);
        },
        child: SongListWidget(
          song: songsTaken[index],
          paddingForTop: 0,
          dotsClicked: () {
            widget.onDotsClicked(songsTaken[index]);
          },
        ));
  }

  Row widgetInfoFilter(BuildContext context, String text, VoidCallback func) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        IconButton(
            onPressed: func,
            padding: EdgeInsets.only(left: 5),
            constraints: BoxConstraints(),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            )),
      ],
    );
  }

  dynamic widgetForSpace(double height, double width) {
    return SizedBox(
      height: SizeConfig.safeBlockVertical! * height,
      width: SizeConfig.safeBlockHorizontal! * width,
    );
  }

  Future getSongs() async {
    if (widget.wifi) {
      setState(() {
        progressSearching = true;
      });
      await FirebaseFirestoreService()
          .getSongDatas(lastSongId, Lists().languagesGetter(selectedLanguage),
              Lists().musicGenresGetter(selectedMusicGenre),context)
          .then((value) {
        if (lastSongId != "" && value.isEmpty) {
          visibility1 = false;
        }
        for (var i = 0; i < value.length; i++) {
          songsTaken.add(value[i]);
          if (i == value.length - 1) {
            lastSongId = value[i].songId;
          }
        }
        setState(() {
          progressSearching = false;
        });
        if(songsTaken.length>30){
          songsTaken.removeRange(30, songsTaken.length);
        }
        box.put(
            "lastSongs|${Lists().languagesGetter(selectedLanguage)}|${Lists().musicGenresGetter(selectedMusicGenre)}",
            songsTaken);
      });
    }
  }

  dynamic lastWidgets() {
    return Column(
      children: [
        widgetForSpace(5, 0),
        progressSearching
            ? const CircularProgressIndicator(
                color: Colors.grey,
              )
            : Visibility(
                visible: visibility1,
                child: ElevatedButton(
                  onPressed: () {
                    getSongs();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(backgroundColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: fourthColor)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9.0, vertical: 12),
                    child: Text(
                      'See more',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: fourthColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
        widgetForSpace(21, 0)
      ],
    );
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

  @override
  bool get wantKeepAlive => true;
}
