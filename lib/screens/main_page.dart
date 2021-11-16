import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_music/UIs/scroller_text/song_player.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/firebase/firebase_firestore.dart';
import 'package:free_music/lists.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/screens/home_page.dart';
import 'package:free_music/screens/library_page.dart';
import 'package:free_music/screens/playlist_adding_page.dart';
import 'package:free_music/screens/search_page.dart';
import 'package:free_music/screens/settings_page.dart';
import 'package:free_music/screens/studio_page.dart';
import 'package:free_music/size.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Song? currentPlayingSong;
  dynamic currentOwnSong;
  int _bottomSelectedIndex = 0;
  int durationOfSong = 0;
  Duration? total;
  Duration? current;
  final player = AudioPlayer();
  bool isSongPlayerPlaying = false;
  bool isSongLoading = false;
  bool newSong = true;
  bool isSignIn = false;
  Wifi wifi = Wifi.ready;
  Playlist? currentPlaylist;
  StreamSubscription? streamForWifi;

  var box = Hive.box('database');

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listeners();
    WidgetsBinding.instance!.addPostFrameCallback((_) => checkSignIn());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamForWifi!.cancel();
  }

  void checkSignIn() {
    if (FirebaseAuthService().getEmail() == "") {
      Route route = MaterialPageRoute(
          builder: (context) => const SettingsPage(
                isFirstPage: true,
              ));
      Navigator.pushReplacement(context, route);
    } else {
      setState(() {
        isSignIn = true;
      });
    }
  }

  void listeners() {
    streamForWifi = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result==ConnectivityResult.none) {
        setState(() {
          wifi=Wifi.notConnected;
        });
      } else {
        setState(() {
          wifi=Wifi.connected;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          wifi=Wifi.ready;
        });
      }
    });

    player.currentIndexStream.listen((event) {
      if (currentPlaylist != null) {
        if (currentPlaylist!.songs[event!].runtimeType == Song) {
          onDataChange(currentPlaylist!.songs[event], true, null);
        } else {
          onDataChange(null, true, currentPlaylist!.songs[event]);
        }
      }
    });

    player.playerStateStream.listen((event) {
      if (event.playing) {
        setState(() {
          isSongPlayerPlaying = true;
        });
      } else {
        setState(() {
          isSongPlayerPlaying = false;
        });
      }
      if (event.processingState == ProcessingState.completed) {
        setState(() {
          isSongPlayerPlaying = false;
          current = total;
        });
      }
      if (event.processingState == ProcessingState.loading) {
        setState(() {
          isSongLoading = true;
        });
      }
      if (event.processingState == ProcessingState.ready) {
        setState(() {
          isSongLoading = false;
        });
      }
    });

    player.durationStream.listen((d) {
      setState(() {
        total = d;
      });
      durationOfSong = d!.inSeconds;
    });

    player.positionStream.listen((p) {
      setState(() {
        current = p;
      });
      if (p.inSeconds == 0) {
        newSong = true;
      }
      if (currentPlayingSong != null &&
          newSong &&
          p.inSeconds > (durationOfSong) / 2) {
        FirebaseFirestoreService().increaseView(currentPlayingSong!.songId);
        newSong = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: !isSignIn
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : mainWidgets(context),
    );
  }

  Stack mainWidgets(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildPageView(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _bottomSelectedIndex == 2
                ? const SizedBox.shrink()
                : currentPlayingSong == null && currentOwnSong == null
                    ? const SizedBox.shrink()
                    : SongPlayer(
                        isLoading: isSongLoading,
                        current: current ?? const Duration(seconds: 0),
                        total: total ?? const Duration(seconds: 5),
                        artistName: currentPlayingSong == null
                            ? FirebaseAuthService().getUsername()
                            : currentPlayingSong!.artistName,
                        songName: currentPlayingSong == null
                            ? currentOwnSong['name']
                            : currentPlayingSong!.songName,
                        isPlaylist: currentPlaylist == null ? false : true,
                        funcForCommands: (value) {
                          if (value == "true") {
                            startPlaying();
                          } else if (value == "false") {
                            pausePlaying();
                          } else if (value == "skipNextSong") {
                            skipNextSong();
                          }
                        },
                        isSongPlayerPlaying: isSongPlayerPlaying,
                      ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 1.5,
            ),
            bottomBar(context),
          ],
        ),
      ],
    );
  }

  dynamic bottomBar(BuildContext context) {
    return Column(
      children: [
        wifi == Wifi.ready
            ? const SizedBox.shrink()
            : AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: MediaQuery.of(context).size.width,
                color: wifi == Wifi.notConnected ? Colors.red : Colors.green,
                child: Text(
                  wifi == Wifi.notConnected
                      ? "No internet connection!"
                      : "Conntected again!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white),
                ),
              ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: SizeConfig.safeBlockVertical! * 8.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              bottomNavigatonBarIcons(
                  0, "Home", Icons.home, Icons.home_outlined),
              bottomNavigatonBarIcons(
                  1, "Search", Icons.search, Icons.search_outlined),
              bottomNavigatonBarIcons(2, "Studio", Icons.mic, Icons.mic_none),
              bottomNavigatonBarIcons(3, "Library", Icons.library_music,
                  Icons.library_music_outlined),
            ],
          ),
        ),
      ],
    );
  }

  dynamic bottomNavigatonBarIcons(
      int index, String text, IconData iconOne, IconData iconTwo) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        bottomTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bottomSelectedIndex == index
              ? Icon(
                  iconOne,
                  color: Colors.white,
                )
              : Icon(
                  iconTwo,
                  color: Colors.grey[700],
                ),
          Text(
            text,
            style: TextStyle(
                color: _bottomSelectedIndex == index
                    ? Colors.white
                    : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Future playSong() async {
    await player.setUrl(currentPlayingSong == null
        ? currentOwnSong['songUrl']
        : currentPlayingSong!.songUrl);

    startPlaying();
  }

  Future startPlaying() async {
    if (player.playerState.processingState == ProcessingState.completed) {
      await player.seek(const Duration());
    }
    player.play();
  }

  Future pausePlaying() async {
    await player.pause();
  }

  Future skipNextSong() async {
    await player.seekToNext();
    startPlaying();
  }

  Future setPlaylist() async {
    List<AudioSource> children = await getSongsAsUri();
    await player.setAudioSource(
      ConcatenatingAudioSource(
        children: children,
      ),
    );
    startPlaying();
  }

  Future<List<AudioSource>> getSongsAsUri() async {
    List<AudioSource> returnList = [];
    for (var i = 0; i < currentPlaylist!.songs.length; i++) {
      returnList.add(AudioSource.uri(Uri.parse(
          currentPlaylist!.songs[i].runtimeType == Song
              ? currentPlaylist!.songs[i].songUrl
              : currentPlaylist!.songs[i]['songUrl'])));
    }
    return returnList;
  }

  //UZUN SÜRE BEKLEYİNCE FİRESTORE BİDAHA VERİ VERMİYOR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  void onDataChange(Song? data, bool isPlaylist, var ownSong) {
    if (data == null) {
      currentPlayingSong = null;
      if (currentOwnSong == null) {
        currentOwnSong = ownSong;
        if (!isPlaylist) {
          currentPlaylist = null;
          playSong();
        }
      } else {
        if (ownSong['path'].split("/")[3] ==
            currentOwnSong['path'].split("/")[3]) {
          startPlaying();
        } else {
          setState(() {
            currentOwnSong = ownSong;
          });
          if (!isPlaylist) {
            currentPlaylist = null;
            playSong();
          }
        }
      }
    } else {
      if (currentPlayingSong == null) {
        currentPlayingSong = data;
        if (!isPlaylist) {
          currentPlaylist = null;
          playSong();
        }
      } else {
        if (currentPlayingSong!.songId == data.songId) {
          startPlaying();
        } else {
          setState(() {
            currentPlayingSong = data;
          });
          if (!isPlaylist) {
            currentPlaylist = null;
            playSong();
          }
        }
      }
    }
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

  PageView buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        HomePage(
          onDataChange: onResultGet,
          onDotsClicked: onDotsClicked,
        ),
        SearchPage(
          onDataChange: onResultGet,
          onDotsClicked: onDotsClicked,
          isNormal: true,
        ),
        const StudioPage(),
        LibraryPage(
          onResultGet: onResultGet,
          onPageChanging: (index) {
            bottomTapped(index);
          },
        ),
      ],
    );
  }

  void onResultGet(value) {
    if (value.runtimeType == Song) {
      onDataChange(value, false, null);
    } else if (value.runtimeType == Playlist) {
      currentPlaylist = value;
      setPlaylist();
    } else {
      onDataChange(null, false, value);
    }
  }

  void pageChanged(int index) {
    setState(() {
      _bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _bottomSelectedIndex = index;
      pageController.jumpToPage(index);
    });
  }
}
