import 'package:free_music/models/song.dart';
import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId : 2)
class Playlist {
  Playlist(
      {required this.name, required this.songs, required this.createdDate});

  @HiveField(0)
  final String name;
  @HiveField(1)
  List songs;
  @HiveField(2)
  final DateTime createdDate;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'songs': songs,
      'createdDate': createdDate,
    };
  }

}
