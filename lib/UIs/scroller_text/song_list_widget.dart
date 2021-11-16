import 'package:flutter/material.dart';
import 'package:free_music/colors.dart';
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/size.dart';

class SongListWidget extends StatelessWidget {
  final dynamic song;
  final Function()? dotsClicked;
  final double? paddingForTop;
  const SongListWidget({Key? key, required this.song, this.dotsClicked, this.paddingForTop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: paddingForTop??10),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.runtimeType==Song? song.songName:song['name'],
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    paddingForTop==0.31? SizedBox(
                        height: SizeConfig.safeBlockHorizontal! * 5,
                        width: SizeConfig.safeBlockHorizontal! * 5,
                        child: const FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                      ):Visibility(
                      visible:song.runtimeType!=Song || song.isExplicit,
                      child: SizedBox(
                        height: SizeConfig.safeBlockHorizontal! * 5,
                        width: SizeConfig.safeBlockHorizontal! * 5,
                        child: const FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.explicit,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        paddingForTop==0.31?FirebaseAuthService().getUsername():song.artistName,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          Visibility(
            visible: dotsClicked!=null||paddingForTop!=0.31,
            child: IconButton(
              onPressed: dotsClicked,
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

}
