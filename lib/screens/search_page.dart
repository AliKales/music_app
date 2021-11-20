import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_music/UIs/scroller_text/search_bar.dart';
import 'package:free_music/UIs/scroller_text/song_list_widget.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_firestore.dart';
import 'package:free_music/functions.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class SearchPage extends StatefulWidget {
  final Function(Song)? onDataChange;
  final Function(Song)? onDotsClicked;
  final Playlist? playlist;
  final bool isNormal;
  final bool? wifi;
  const SearchPage(
      {Key? key,
      this.onDataChange,
      this.onDotsClicked,
      required this.isNormal,
      this.playlist,
      this.wifi})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController tECsearchBar = TextEditingController();
  ////////////////////////Search yaptığında listeye padding koy
  bool isSearchBarActive = false;
  bool isSearchBarTextActive = false;
  bool progressSearching = false;

  List<Song> songsTaken = [];
  List songsLastSearched = [];
  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => gel());
  }

  void gel() {
    setState(() {
      songsLastSearched = box.get("songsLastSearched") ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isNormal) {
      return widgetsNormal(context);
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: FloatingActionButton(
            backgroundColor: thirdColor,
            child: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        body: widgetsNormal(context),
      );
    }
  }

  SafeArea widgetsNormal(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            height: SizeConfig.safeBlockVertical! * 9,
            color: Colors.grey.shade800,
            child: SearchBar(
              fSearch: (stringSearched) {
                if (stringSearched == "ozel_admin_code:001") {
                  setState(() {
                    songsTaken = [];
                  });
                } else {
                  setState(() {
                    songsTaken = [];
                  });
                  getSongs(
                      stringSearched.trim().replaceAll(" ", "").toLowerCase());
                }
              },
            ),
          ),
          progressSearching
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  ),
                )
              : songsTaken.isNotEmpty
                  ? listWidget(songsTaken, 10)
                  : Visibility(
                      visible: songsLastSearched.isNotEmpty,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Yakındaki Aramalar",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                              listWidget(songsLastSearched, 0),
                            ],
                          ),
                        ),
                      ),
                    )
        ],
      ),
    );
  }

  Expanded listWidget(listSent, double padding) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
          itemCount: listSent.length + 1,
          itemBuilder: (_, index) {
            if (index == listSent.length) {
              return SizedBox(
                height: SizeConfig.safeBlockVertical! * 20,
              );
            } else {
              if (index < listSent.length - 1) {
                return Column(
                  children: [
                    widgetSongLists(index, listSent),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: Colors.white,
                        height: SizeConfig.safeBlockVertical! * 0.5,
                      ),
                    )
                  ],
                );
              } else {
                return widgetSongLists(index, listSent);
              }
            }
          },
        ),
      ),
    );
  }

  InkWell widgetSongLists(int index, listSent) {
    return InkWell(
        onTap: () {
          if (widget.isNormal) {
            normalWidgetFunc(index, listSent);
          } else {
            if (widget.playlist!.songs.any(
                (element) => element.songName == listSent[index].songName)) {
              Functions().showToast("This song already exits", null);
            } else {
              Navigator.pop(context, listSent[index]);
            }
          }
        },
        child: SongListWidget(
            dotsClicked: widget.isNormal
                ? () {
                    widget.onDotsClicked!(listSent[index]);
                  }
                : null,
            song: listSent[index]));
  }

  void normalWidgetFunc(int index, listSent) {
    Song song = listSent[index];
    widget.onDataChange!(song);
    songsLastSearched.removeWhere((element) => element.songId == song.songId);
    songsLastSearched.insert(0, song);

    if (songsLastSearched.length > 10) {
      songsLastSearched.removeLast();
    }
    box.put("songsLastSearched", songsLastSearched);
  }

  Future getSongs(String searchedString) async {
    final bool wifi =
        widget.wifi ?? await Functions().checkInternetConnection();
    if (wifi) {
      songsTaken = [];
      setState(() {
        progressSearching = true;
      });
      await FirebaseFirestoreService()
          .getSongDatasForSearch(searchedString, context)
          .then((value) {
        for (var i = 0; i < value.length; i++) {
          songsTaken.add(value[i]);
        }
        setState(() {
          progressSearching = false;
        });
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
