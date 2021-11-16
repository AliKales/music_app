import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:free_music/UIs/scroller_text/scroller_text.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/size.dart';

class SongPlayer extends StatefulWidget {
  final String songName;
  final String artistName;
  final bool isSongPlayerPlaying;
  final Duration total;
  final Duration current;
  final Function(String) funcForCommands;
  final bool isPlaylist;
  final bool isLoading;
  const SongPlayer(
      {Key? key,
      required this.songName,
      required this.artistName,
      required this.isSongPlayerPlaying,
      required this.funcForCommands,
      required this.total,
      required this.current,
      required this.isPlaylist,
      required this.isLoading})
      : super(key: key);

  @override
  _SongPlayerState createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.isSongPlayerPlaying ? controller!.forward() : controller?.reverse();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      height: SizeConfig.safeBlockVertical! * 9,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: thirdColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: SizeConfig.safeBlockVertical! * 1.2,
                      ),
                      Expanded(
                        child: ScrollerText(
                          text: widget.songName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                          alignment: Alignment.bottomLeft,
                        ),
                      ),
                      Expanded(
                        child: ScrollerText(
                          text: widget.artistName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.grey),
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                widget.isLoading
                    ? SizedBox(
                        height: SizeConfig.safeBlockVertical! * 2.5,
                        child: const FittedBox(
                          fit: BoxFit.contain,
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        ))
                    : IconButton(
                        onPressed: () {
                          if (widget.isSongPlayerPlaying) {
                            widget.funcForCommands("false");
                          } else {
                            widget.funcForCommands("true");
                          }
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: const EdgeInsets.only(left: 5),
                        constraints: const BoxConstraints(),
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: controller!,
                          color: Colors.white,
                        ),
                      ),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal! * 3,
                ),
                Visibility(
                  visible: widget.isPlaylist && !widget.isLoading,
                  child: IconButton(
                    onPressed: () {
                      widget.funcForCommands("skipNextSong");
                    },
                    padding: const EdgeInsets.only(left: 5),
                    constraints: const BoxConstraints(),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(
                      Icons.skip_next_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ProgressBar(
            progress: widget.current,
            progressBarColor: Colors.white,
            total: widget.total,
            baseBarColor: Colors.grey.withOpacity(0.4),
            timeLabelLocation: TimeLabelLocation.none,
            thumbRadius: 0,
            barHeight: SizeConfig.safeBlockVertical! * 0.3,
          ),
        ],
      ),
    );
  }
}
