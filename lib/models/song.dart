import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId : 1)
class Song {
  Song(
      {required this.songName,
      required this.artistName,
      required this.language,
      required this.genre,
      required this.songId,
      required this.date,
      required this.isExplicit,
      required this.views,
      required this.pathToSong,
      required this.songUrl,
      required this.songNameForDB});

  @HiveField(0)
  String songId;
  @HiveField(1)
  final String songName;
  @HiveField(2)
  final String artistName;
  @HiveField(3)
  final String language;
  @HiveField(4)
  final String genre;
  @HiveField(5)
  final String date;
  @HiveField(6)
  final bool isExplicit;
  @HiveField(7)
  final int views;
  @HiveField(8)
  final String pathToSong;
  @HiveField(9)
  String songUrl;
  @HiveField(10)
  final String songNameForDB;

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'songName': songName,
      'artistName': artistName,
      'language': language,
      'genre': genre,
      'date': date,
      'isExplicit': isExplicit,
      'views': views,
      'pathToSong': pathToSong,
      'songUrl':songUrl,
      'songNameForDB':songNameForDB
    };
  }

  Song.fromJson(Map json)
      : this(
          songName: json['songName'],
          artistName: json['artistName'],
          language: json['language'],
          genre: json['genre'],
          songId: json['songId'],
          date: json['date'],
          isExplicit: json['isExplicit'],
          views: json['views'],
          pathToSong: json['pathToSong'],
          songUrl:json['songUrl'],
          songNameForDB:json['songNameForDB']
        );
}
