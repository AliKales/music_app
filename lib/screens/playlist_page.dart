import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:free_music/UIs/scroller_text/custom_appbar.dart';
import 'package:free_music/UIs/scroller_text/song_list_widget.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_firestore.dart';
import 'package:free_music/functions.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/screens/playlist_adding_page.dart';
import 'package:free_music/screens/search_page.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final int playlistCounter;
  const PlaylistPage(
      {Key? key, required this.playlist, required this.playlistCounter})
      : super(key: key);

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  var box = Hive.box('database');
  ScrollController? _scrollController;
  ScrollController? _scrollController2;
  double opacity = 0;
  bool progress1 = true;
  bool noSong = false;
  Playlist? playlist;

  @override
  void initState() {
    super.initState();
    if (widget.playlistCounter < 0) {
      _scrollController2 = ScrollController();
      _scrollController2!.addListener(_scrollListenerNonCreatedPlaylists);
    } else {
      _scrollController = ScrollController();
      _scrollController!.addListener(_scrollListener);
    }
    if (widget.playlistCounter == -1) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => gel());
    } else if (widget.playlistCounter == -2) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        gel2();
      });
    }
  }

  void gel2() {
    playlist = widget.playlist;
    setState(() {
      progress1 = false;
    });
  }

  Future<void> gel() async {
    Functions().checkInternetConnection().then((value) async {
      if (value) {
        List listGet = await FirebaseFirestoreService().getOwnSongs(
            widget.playlist.songs.isEmpty ? [] : widget.playlist.songs);
        if (listGet.isEmpty) {
          setState(() {
            noSong = true;
          });
        } else if (listGet[0] == 31) {
          playlist = widget.playlist;
          setState(() {
            progress1 = false;
          });
        } else {
          playlist = Playlist(
              name: widget.playlist.name,
              songs: listGet,
              createdDate: DateTime.now());
          box.put("ownSongs", playlist);
          setState(() {
            progress1 = false;
          });
        }
      } else {
        Functions().showToast("No internet connection!", null);
        setState(() {
          playlist = Playlist(
              name: widget.playlist.name,
              songs: widget.playlist.songs,
              createdDate: DateTime.now());
          progress1 = false;
        });
      }
    });
  }

  _scrollListener() {
    if (_scrollController!.offset.toInt() / 200 < 1) {
      setState(() {
        opacity = _scrollController!.offset.toInt() / 200;
      });
    }
  }

  _scrollListenerNonCreatedPlaylists() {
    if (_scrollController2!.offset.toInt() / 80 <= 2) {
      setState(() {
        opacity = _scrollController2!.offset.toInt() / 80;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playlistCounter < 0) {
      return scaffoldNonCreatedPlaylists();
    } else {
      return scaffoldCreatedPlaylists();
    }
  }

  Scaffold scaffoldNonCreatedPlaylists() {
    return Scaffold(
      floatingActionButton: playlist == null || playlist!.songs.length <= 1
          ? null
          : floatingActionButton(),
      backgroundColor: backgroundColor,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (value) {
          value.disallowIndicator();
          return true;
        },
        child: NestedScrollView(
            controller: _scrollController2,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white.withOpacity(0),
                  shadowColor: Colors.white.withOpacity(0),
                  elevation: 0,
                  flexibleSpace: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/backgrounds/playlist arkaplan.png"),
                                          fit: BoxFit.fitWidth)),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.maxFinite,
                                    height: SizeConfig.safeBlockVertical! * 15,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          backgroundColor.withOpacity(0.8),
                                          backgroundColor.withOpacity(0)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.maxFinite,
                            height: SizeConfig.safeBlockVertical! * 3.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  backgroundColor.withOpacity(0.8),
                                  backgroundColor.withOpacity(0)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.none,
                        background: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: SizeConfig.safeBlockVertical! * 4,
                              ),
                              SizedBox(
                                width: opacity > 1
                                    ? 0
                                    : MediaQuery.of(context).size.width -
                                        opacity *
                                            MediaQuery.of(context).size.width,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.playlist.name,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  title: Text(
                    widget.playlist.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(opacity / 2),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size(double.infinity, kToolbarHeight),
                    child: Stack(
                      children: [getButton()],
                    ),
                  ),
                ),
              ];
            },
            body: widgetListView()),
      ),
    );
  }

  dynamic getButton() {
    if (widget.playlistCounter == -1) {
      return buttonForBottom(context, "Record song", () {
        Navigator.pop(context, "recordSong");
      });
    } else {
      if (progress1) {
        return const CircularProgressIndicator(color: Colors.green);
      } else {
        return buttonForBottom(context, "Karışık çal", () {
          funcFloatingActionButton();
        });
      }
    }
  }

  ElevatedButton buttonForBottom(BuildContext context, String text, function) {
    return ElevatedButton(
      onPressed: function,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 12),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Column widgetTextName(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.safeBlockHorizontal! * 15),
        SizedBox(
          width: MediaQuery.of(context).size.width -
              opacity * (MediaQuery.of(context).size.width / 1.8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "playlist!.name",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5!.copyWith(
                  color: Colors.white.withOpacity(1 - opacity),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  dynamic widgetListView() {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: getWidget1(),
    );
  }

  dynamic getWidget1() {
    if (noSong) {
      return Center(
        child: Text(
          "No Song Found!",
          style: Theme.of(context)
              .textTheme
              .headline4!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      if (progress1) {
        return circularProgress();
      } else {
        return listView();
      }
    }
  }

  ListView listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlist!.songs.length,
      itemBuilder: (_, index) {
        return Column(
          children: [
            widgetSongLists(index),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Divider(
                color: Colors.white,
                height: SizeConfig.safeBlockVertical! * 0.5,
              ),
            )
          ],
        );
      },
    );
  }

  SizedBox circularProgress() {
    return SizedBox(
      width: SizeConfig.safeBlockHorizontal! * 5,
      height: SizeConfig.safeBlockHorizontal! * 5,
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      ),
    );
  }

  Column buttonPlayer(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.safeBlockHorizontal! * 30),
        ElevatedButton(
          onPressed: () async {
            funcFloatingActionButton();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 12),
            child: Text(
              'Karışık çal',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Scaffold scaffoldCreatedPlaylists() {
    return Scaffold(
      floatingActionButton:
          widget.playlist.songs.length <= 1 ? null : floatingActionButton(),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.playlist.name,
          style: TextStyle(color: Colors.white.withOpacity(opacity)),
        ),
        backgroundColor: Color(0xFF322423),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF322423).withOpacity(opacity),
              backgroundColor.withOpacity(opacity),
            ],
          )),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF322423),
                      Color(0xFF121212),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: SizeConfig.safeBlockHorizontal! * 15),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        widget.playlist.name,
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Route route = MaterialPageRoute(
                            builder: (context) => SearchPage(
                                  isNormal: false,
                                  playlist: widget.playlist,
                                ));
                        final result = await Navigator.push(context, route);
                        widget.playlist.songs.insert(0, result);
                        List pl = box.get("playlists");
                        pl[widget.playlistCounter] = widget.playlist;
                        box.put("playlists", pl);
                        setState(() {});
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
                          'Şarkı Ekle',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockHorizontal! * 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Visibility(
                  visible: widget.playlist.songs.isNotEmpty,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ekledin",
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.playlist.songs.length,
                  itemBuilder: (_, index) {
                    return Column(
                      children: [
                        widgetSongLists(index),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Divider(
                            color: Colors.white,
                            height: SizeConfig.safeBlockVertical! * 0.5,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton() {
    return FloatingActionButton.small(
      onPressed: () {
        funcFloatingActionButton();
      },
      backgroundColor: Colors.green,
      child: const Icon(
        Icons.playlist_play,
        color: Colors.black,
      ),
    );
  }

  void funcFloatingActionButton() {
    if (playlist != null && playlist!.songs.length > 1) {
      Navigator.pop(context, playlist);
    } else if (widget.playlist.songs.length > 1) {
      Navigator.pop(context, widget.playlist);
    }
  }

  InkWell widgetSongLists(int index) {
    return InkWell(
        onTap: () {
          if (playlist != null) {
            Navigator.pop(context, playlist!.songs[index]);
          } else {
            Navigator.pop(context, widget.playlist.songs[index]);
          }
        },
        child: SongListWidget(
          //if padding is "0.31", that means this is for own songs
          paddingForTop: widget.playlistCounter >= 0 ? 0 : 0.31,
          song: widget.playlistCounter >= 0
              ? widget.playlist.songs[index]
              : playlist!.songs[index],
          dotsClicked: () {
            onDotsClicked(playlist!.songs[index]);
          },
        ));
  }

  Future<void> onDotsClicked(Song data) async {
    int func = 0;
    bool isLiked = false;
    Playlist likedSongs = box.get("likedSongs") ??
        Playlist(name: "likedSongs", songs: [], createdDate: DateTime.now());
    isLiked = likedSongs.songs.any((element) => element.songId == data.songId);
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black,
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.safeBlockVertical! * 10),
              Align(
                alignment: Alignment.center,
                child: Text(data.songName,
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(data.artistName,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: SizeConfig.safeBlockVertical! * 20),
              !isLiked
                  ? widgetTextButtonForDotsClicked(() {
                      func = 1;
                      Navigator.pop(context);
                    }, "Beğen", Icons.favorite_outline_rounded)
                  : widgetTextButtonForDotsClicked(() {
                      func = 2;
                      Navigator.pop(context);
                    }, "Beğenildi", Icons.favorite_rounded),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              widgetTextButtonForDotsClicked(() {
                func = 3;
                Navigator.pop(context);
              }, "Çalma Listesine Ekle", Icons.playlist_add),
            ],
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
    ////////////////
    if (func == 1) {
      //add to liked song
      likedSongs.songs.insert(0, data);
      box.put("likedSongs", likedSongs);
    } else if (func == 2) {
      likedSongs.songs.removeWhere((element) => element.songId == data.songId);
      box.put("likedSongs", likedSongs);
    } else if (func == 3) {
      //add to playlist
      await Future.delayed(const Duration(milliseconds: 700));
      Route route = MaterialPageRoute(builder: (context) {
        return PlaylistAdding(
          song: data,
        );
      });
      Navigator.push(context, route);
    }
    setState(() {});
  }

  TextButton widgetTextButtonForDotsClicked(
      Function() click, String text, IconData icon) {
    return TextButton.icon(
      onPressed: click,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      label: Text(text,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
