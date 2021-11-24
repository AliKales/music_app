import 'package:flutter/material.dart';
import 'package:free_music/UIs/scroller_text/profile_photo.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/screens/playlist_page.dart';
import 'package:free_music/screens/settings_page.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class LibraryPage extends StatefulWidget {
  final Function(dynamic) onResultGet;
  final Function(int) onPageChanging;
  const LibraryPage(
      {Key? key,
      required this.onResultGet,
      required this.onPageChanging})
      : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List items = [
    {"name": "Kendi Şarkıların", "id": 1},
    {"name": "Çalma Listeleri", "id": 2},
    {"name": "Şarkılar", "id": 3},
  ];

  Map itemSelected = {};

  List itemsForBody = [];
  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsForBody.add(box.get("likedSongs") ??
        Playlist(name: "likedSongs", songs: [], createdDate: DateTime.now()));
    itemsForBody.add(box.get("ownSongs") ??
        Playlist(name: "ownSongs", songs: [], createdDate: DateTime.now()));
    itemsForBody += box.get("playlists") ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: [
            Row(
              children: [
                widgetProfilePhoto(context),
                SizedBox(width: SizeConfig.safeBlockHorizontal! * 4),
                Text("Library",
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            body()
          ],
        ),
      ),
    );
  }

  dynamic body() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: ListView.builder(
              itemCount: itemsForBody.length,
              itemBuilder: (_, index) {
                return widgetForList(index);
              }),
        ),
      ),
    );
  }

  Future<void> funcForWidgetForList(index) async {
    Route route = MaterialPageRoute(
        builder: (context) => PlaylistPage(
              playlist: itemsForBody[index],
              playlistCounter: index - 2,
            ));
    final result = await Navigator.push(context, route);
    setState(() {});
    if (result != null) {
      if (result == "recordSong") {
        widget.onPageChanging(2);
      } else {
        widget.onResultGet(result);
      }
    }
  }

  dynamic widgetForList(index) {
    return InkWell(
      onTap: () {
        funcForWidgetForList(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              height: SizeConfig.safeBlockHorizontal! * 12,
              width: SizeConfig.safeBlockHorizontal! * 12,
              decoration: BoxDecoration(
                color: index > 1 ? Colors.grey[800] : null,
                gradient: index > 1
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0011a7),
                          Color(0xFFcceef7),
                        ],
                      ),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: iconForListWidgets(index),
            ),
            SizedBox(
              width: SizeConfig.safeBlockHorizontal! * 2,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getNameOfPlaylist(index),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical! * 0.7,
                  ),
                  index > 1
                      ? textPlaylist(index)
                      : Row(
                          children: [
                            SizedBox(
                                width: SizeConfig.safeBlockHorizontal! * 3.8,
                                height: SizeConfig.safeBlockHorizontal! * 3.8,
                                child: const FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(
                                    Icons.push_pin_rounded,
                                    color: Colors.green,
                                  ),
                                )),
                            Expanded(
                              child: textPlaylist(index),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String getNameOfPlaylist(index){
    switch (index) {
      case 0:
        return "Liked Songs";
      case 1:
        return "Own Songs";
      default:
        return itemsForBody[index].name;
    }
  }

  Icon iconForListWidgets(index) {
    if (index > 1) {
      return const Icon(
        Icons.music_note_outlined,
        color: Colors.white,
      );
    } else if (index == 1) {
      return const Icon(
        Icons.mic,
        color: Colors.white,
      );
    } else {
      return const Icon(
        Icons.favorite,
        color: Colors.white,
      );
    }
  }

  Text textPlaylist(index) {
    return Text(
      index == 1
          ? "Playlist"
          : "Playlist ● ${itemsForBody[index].songs.length} Song",
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
      style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: Colors.grey,
          ),
    );
  }

  Row widgetRowWhenItemSelected() {
    return Row(
      children: [
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 5,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  itemSelected = {};
                });
              },
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: const Icon(
                Icons.cancel_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal! * 3,
        ),
        tab(itemSelected['name'], itemSelected['id'])
      ],
    );
  }

  InkWell widgetProfilePhoto(BuildContext context) {
    return InkWell(
      onTap: () async {
        Route route = MaterialPageRoute(builder: (_) {
          return const SettingsPage();
        });
        await Navigator.push(context, route);
        setState(() {});
      },
      child: ProfilePhoto(
          context: context, size: SizeConfig.safeBlockHorizontal! * 8),
    );
  }

  InkWell tab(String text, int index) {
    return InkWell(
      onTap: () {
        if (itemSelected.isNotEmpty) {
          setState(() {
            itemSelected = {};
          });
        } else {
          setState(() {
            itemSelected = items[index];
          });
        }
      },
      child: Container(
        height: SizeConfig.safeBlockVertical! * 6,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(50))),
        child: FittedBox(
          fit: BoxFit.cover,
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
