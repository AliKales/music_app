// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 1;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      songName: fields[1] as String,
      artistName: fields[2] as String,
      language: fields[3] as String,
      genre: fields[4] as String,
      songId: fields[0] as String,
      date: fields[5] as String,
      isExplicit: fields[6] as bool,
      views: fields[7] as int,
      pathToSong: fields[8] as String,
      songUrl: fields[9] as String,
      songNameForDB: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.songId)
      ..writeByte(1)
      ..write(obj.songName)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.genre)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.isExplicit)
      ..writeByte(7)
      ..write(obj.views)
      ..writeByte(8)
      ..write(obj.pathToSong)
      ..writeByte(9)
      ..write(obj.songUrl)
      ..writeByte(10)
      ..write(obj.songNameForDB);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
