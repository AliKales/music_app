import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/functions.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class PlaylistAdding extends StatefulWidget {
  final Song song;
  const PlaylistAdding({Key? key, required this.song}) : super(key: key);

  @override
  State<PlaylistAdding> createState() => _PlaylistAddingState();
}

class _PlaylistAddingState extends State<PlaylistAdding> {
  List playlists = [];
  var box = Hive.box('database');
  bool isAddingPlaylist = false;
  bool progress1 = false;
  TextEditingController tECPlaylist = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();  
    playlists = box.get("playlists") ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: isAddingPlaylist
            ? null
            : AppBar(
                backgroundColor: backgroundColor,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined,
                      color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                elevation: 0,
                title: const Text(
                  "Add to playlist",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
        body: Stack(
          children: [
            playlistsPage(context),
            Visibility(
              visible: isAddingPlaylist,
              child: addPlaylistPage(context),
            ),
          ],
        ));
  }

  Container addPlaylistPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7b7b7b),
            backgroundColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Give a name to playlist",
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: SizeConfig.safeBlockVertical! * 5),
            TextField(
              autofocus: false,
              controller: tECPlaylist,
              inputFormatters: [
                FilteringTextInputFormatter(
                    RegExp(
                        r"""^[\p{L}0-9 @,.<>#₺_&\-+()/*"':;!?~`|•√π÷×∆£€$¢^°={}%©®™√[\]]*$""",
                        caseSensitive: false, unicode: true, dotAll: true),
                    allow: true),
              ],
              onChanged: (text) {},
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                isDense: true,
                contentPadding: EdgeInsets.all(15),
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical! * 10),
            progress1
                ? const CircularProgressIndicator(
                    color: Colors.green,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () => setState(() {
                                isAddingPlaylist = false;
                              }),
                          style: TextButton.styleFrom(primary: Colors.black),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          )),
                      TextButton(
                          onPressed: () {
                            if (tECPlaylist.text == "") {
                              Functions()
                                  .showToast("Playlist name can't be empty",null);
                            } else if (playlists.any((element) =>
                                element.name == tECPlaylist.text)) {
                              Functions().showToast(
                                  "This playlist name already exits",null);
                            } else {
                              setState(() {
                                progress1 = true;
                              });
                              Functions().getCurrentGlobalTime(context).then((value) {
                                playlists.insert(
                                    0,
                                    Playlist(
                                        name: tECPlaylist.text,
                                        songs: [],
                                        createdDate: value));
                                box.put("playlists", playlists);
                                setState(() {
                                  progress1 = false;
                                  isAddingPlaylist = false;
                                  tECPlaylist.clear();
                                });
                              });
                            }
                          },
                          style: TextButton.styleFrom(primary: Colors.black),
                          child: const Text(
                            "Create",
                            style: TextStyle(color: Colors.green),
                          )),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Column playlistsPage(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 7,
        ),
        widgetButtonNewPlaylist(context),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 5,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (_, index) {
                return widgetPlaylistContainer(context, index);
              }),
        )
      ],
    );
  }

  InkWell widgetPlaylistContainer(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Functions().showToast("Double tap for adding",null);
      },
      onDoubleTap: () {
        if (playlists[index]
            .songs
            .any((element) => element.songId == widget.song.songId)) {
          Functions().showToast("This song is already on this playlist",null);
        } else {
          playlists[index].songs.insert(0, widget.song);
          box.put("playlists", playlists);
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: SizeConfig.safeBlockVertical! * 10,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(colors: [
            Color(0xFF6C72CB),
            Color(0xFFCB69C1),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              playlists[index].name,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "- ${FirebaseAuthService().getUsername()}",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton widgetButtonNewPlaylist(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Functions().checkInternetConnection().then((value) {
          if (value) {
            setState(() {
              isAddingPlaylist = true;
            });
          }else{
            Functions().showToast("No internet connection!",null);
          }
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(fourthColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: fourthColor)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 12),
        child: Text(
          'Yeni Çalma Listesi',
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
