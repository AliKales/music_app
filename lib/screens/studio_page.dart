import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_music/UIs/scroller_text/custom_appbar.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/functions.dart';
import 'package:free_music/screens/settings_page.dart';
import 'package:free_music/screens/studio_share_page.dart';
import 'package:free_music/size.dart';
import 'package:permission_handler/permission_handler.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({Key? key}) : super(key: key);

  @override
  _StudioPageState createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage>
    with AutomaticKeepAliveClientMixin<StudioPage> {
  static const platform = MethodChannel('caroby/audioRecorder');

  String path = "";

  bool isRecording = false;
  bool isPlaying = false;
  bool isAudioReady = false;
  bool isDraging = false;

  Duration? currentDuration;
  Duration? totalDuration;

  Timer? timer;
  int counter = 0;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gel();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  Future gel() async {
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });

    audioPlayer.onDurationChanged.listen((Duration p) {
      setState(() {
        totalDuration = p;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() => currentDuration = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        CustomAppbar(
          leftWidgets: [],
          rightWidgets: [
            isAudioReady
                ? InkWell(
                    onTap: () {
                      reset();
                    },
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox.shrink()
          ],
          text: "Studio",
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              SizeConfig.safeBlockVertical! * 30,
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              Visibility(
                visible: isPlaying || isRecording,
                child: Text(
                  getFixedDuration(counter),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: SizeConfig.safeBlockHorizontal! * 50,
                height: SizeConfig.safeBlockHorizontal! * 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: getColorForContainer(),
                        width: isPlaying || isRecording ? 4 : 2)),
                child:
                    FittedBox(fit: BoxFit.contain, child: iconButtonsWidget()),
              ),
              isAudioReady
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: ProgressBar(
                        progress:
                            currentDuration ?? const Duration(milliseconds: 0),
                        //buffered: Duration(milliseconds: 3000),
                        total: totalDuration ?? const Duration(milliseconds: 0),
                        progressBarColor: Colors.red,
                        thumbGlowColor: Colors.transparent,
                        baseBarColor: Colors.white.withOpacity(0.24),
                        bufferedBarColor: Colors.white.withOpacity(0.24),
                        thumbColor:
                            isDraging ? Colors.white : Colors.transparent,
                        timeLabelTextStyle: TextStyle(color: Colors.white70),
                        barHeight: 3.0,
                        thumbRadius: 5.0,
                        onDragEnd: () {
                          setState(() {
                            isDraging = false;
                          });
                        },
                        onDragStart: (value) {
                          setState(() {
                            isDraging = true;
                          });
                          if (isPlaying) {
                            pausePlaying();
                          }
                        },
                        onDragUpdate: (value) {
                          setState(() {
                            currentDuration = value.timeStamp;
                          });
                        },
                        onSeek: (duration) {
                          seekTo(duration).then((value) {
                            if (isPlaying) {
                              startPlaying();
                            }
                          });
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              const Expanded(child: SizedBox()),
              isAudioReady
                  ? ElevatedButton(
                      onPressed: () async {
                        if (counter <= 240) {
                          Route route;
                          if (FirebaseAuthService().getUsername() ==
                              "ozel_admin_code:002") {
                            route = MaterialPageRoute(builder: (context) {
                              return const SettingsPage();
                            });
                          } else {
                            route = MaterialPageRoute(builder: (context) {
                              return StudioSharePage(path: path);
                            });
                          }
                          await Navigator.push(context, route).then((value) {
                            if (value) {
                              reset();
                            }
                          });
                        } else {
                          Functions().showToast(
                              "Maximum 4 minutes!",context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(backgroundColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: fourthColor)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 12),
                        child: Text(
                          'Next',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: fourthColor,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Future reset() async {
    isRecording = false;
    isPlaying = false;
    counter = 0;
    isAudioReady = false;
    currentDuration = null;
    totalDuration = null;
    await audioPlayer.stop();
    await audioPlayer.release();
    setState(() {
      isAudioReady = false;
    });
  }

  Future<bool> handlePermissions() async {
    bool boolReturn = true;
    await [
      Permission.microphone,
      Permission.storage,
    ].request().then((value) => {
          value.forEach((key, value) {
            print(value);
            if (value != PermissionStatus.granted) {
              boolReturn = false;
            }
          })
        });
    return boolReturn;
  }

  dynamic getColorForContainer() {
    if (isDraging) {
      return Colors.yellow;
    } else if (isPlaying || isRecording) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String getFixedDuration(int number) {
    int minute = 0;
    int second = 0;
    for (var i = 60; i <= number; i += 60) {
      minute += 1;
    }
    second = number - minute * 60;

    if (second < 10) {
      return "$minute:0$second";
    } else {
      return "$minute:$second";
    }
  }

  dynamic iconButtonsWidget() {
    if (isAudioReady == false) {
      if (isRecording) {
        return IconButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          disabledColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            stopRecording().then((value) {
              setState(() {
                isRecording = false;
                isAudioReady = true;
              });
            });
          },
          icon: const Icon(
            Icons.stop,
            color: Colors.white70,
          ),
        );
      } else {
        return IconButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          disabledColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            handlePermissions().then((value) {
              if (value) {
                startRecording();
                setState(() {
                  isRecording = true;
                });
              }
            });
          },
          icon: const Icon(
            Icons.mic,
            color: Colors.white70,
          ),
        );
      }
    } else {
      if (isPlaying) {
        return IconButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          disabledColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            pausePlaying().then((value) {
              setState(() {
                isPlaying = false;
              });
            });
          },
          icon: const Icon(
            Icons.pause,
            color: Colors.white70,
          ),
        );
      } else {
        return IconButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          disabledColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            startPlaying();
            setState(() {
              isPlaying = true;
            });
          },
          icon: const Icon(
            Icons.play_arrow,
            color: Colors.white70,
          ),
        );
      }
    }
  }

  Future seekTo(durationToSeek) async {
    await audioPlayer.seek(durationToSeek);
  }

  Future startRecording() async {
    try {
      path = await platform.invokeMethod('startRecording');
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          counter++;
        });
      });
    } catch (e) {
      // Functions().showToast(
      //     "Unexpected error. Please try again later!", ToastGravity.BOTTOM);
    }
  }

  Future stopRecording() async {
    try {
      final String result = await platform.invokeMethod('stopRecording');
      timer!.cancel();
      await audioPlayer.setUrl(path, isLocal: true);
    } catch (e) {
      print(e);
    }
  }

  Future startPlaying() async {
    await audioPlayer.resume();
  }

  Future pausePlaying() async {
    await audioPlayer.pause();
  }

  @override
  bool get wantKeepAlive => true;
}
