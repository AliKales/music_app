import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:free_music/firebase/firebase_auth.dart';
import 'package:free_music/functions.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:hive/hive.dart';

class FirebaseFirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var box = Hive.box('database');

  Future<String> setSongDatas(Song song) async {
    await firebase_storage.FirebaseStorage.instance
        .ref(song.pathToSong)
        .getDownloadURL()
        .then((value) async {
      song.songUrl = value;
      var doc = firestore.collection("songs").doc(song.songId);
      await doc.set(song.toMap());
    });
    return song.songUrl;
  }

  Future<List> getSongDatasForSearch(String searchedString,context) async {
    List listReturn = [];
    try {
      await firestore
        .collection("songs")
        .where('songNameForDB', isGreaterThanOrEqualTo: searchedString)
        .where('songNameForDB', isLessThanOrEqualTo: searchedString + "\uF7FF")
        .limit(5)
        .get()
        .then((querySnapshot) {
      for (var json in querySnapshot.docs) {
        listReturn.add(Song.fromJson(json.data()));
      }
    });
    } on FirebaseException catch (e) {
      if(e.code=="permission-denied"){
        Functions().showAlertDialog(context, "Databases are close. Please try again later!");
      }else{
        Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
      }
    }catch (e){
      Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
    }
    
    return listReturn;
  }

  Future<List> getSongDatas(
      String lastSongId, String language, String genre,context) async {
    List listReturn = [];
    try {
      var ref = firestore.collection("songs");

      if (lastSongId == "") {
        List listFromDatabase = [];
        listFromDatabase = box.get("lastSongs|$language|$genre") ?? [];
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await ref
            .orderBy('songId')
            .where('language', isEqualTo: language)
            .where('genre', isEqualTo: genre)
            .limit(1)
            .get();

        for (var json in querySnapshot.docs) {
          if (listFromDatabase.isNotEmpty &&
              listFromDatabase[0].songId == json.data()['songId']) {
            listReturn = listFromDatabase;
          } else {
            QuerySnapshot<Map<String, dynamic>> querySnapshot2 = await ref
                .orderBy('songId')
                .startAt([json.data()['songId']])
                .where('language', isEqualTo: language)
                .where('genre', isEqualTo: genre)
                .limit(10)
                .get();

            for (var json in querySnapshot2.docs) {
              listReturn.add(Song.fromJson(json.data()));
            }
          }
        }
      } else {
        await ref
            .orderBy("songId")
            .startAfter([lastSongId])
            .where('language', isEqualTo: language)
            .where('genre', isEqualTo: genre)
            .limit(10)
            .get()
            .then((querySnapshot) {
              for (var json in querySnapshot.docs) {
                listReturn.add(Song.fromJson(json.data()));
              }
            });
      }
    } on FirebaseException catch (e) {
      if(e.code=="permission-denied"){
        Functions().showAlertDialog(context, "Databases are close. Please try again later!");
      }else{
        Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
      }
    }catch (e){
      Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
    }

    return listReturn;
  }

  Future putOwnSong(Song song) async {
    await firestore
        .collection("artists")
        .doc(FirebaseAuthService().getUsername())
        .collection("singles")
        .doc(song.songId)
        .set({
      'path': song.pathToSong,
      'name': song.songName,
      'songUrl': song.songUrl,
      'time': double.parse(
          song.songId.split("|")[0].replaceAll(":", "").replaceAll(".", ""))
    });
  }

  Future<List> getOwnSongs(List listFromDatabase,context) async {
    List listReturn = listFromDatabase;

    try {
      await firestore
        .collection("artists")
        .doc(FirebaseAuthService().getUsername())
        .collection("singles")
        .limit(1)
        .get()
        .then((querySnapshot) async {
      for (var json in querySnapshot.docs) {
        if (listFromDatabase.isNotEmpty &&
            listFromDatabase[0]['path'] == json.data()['path']) {
          listReturn = [31];
        } else if (listFromDatabase.isEmpty) {
          await firestore
              .collection("artists")
              .doc(FirebaseAuthService().getUsername())
              .collection("singles")
              .get()
              .then((querySnapshot) {
            for (var json in querySnapshot.docs) {
              listReturn.add(json.data());
            }
          });
          box.put(
              "ownSongs",
              Playlist(
                  name: "ownSongs",
                  songs: listReturn,
                  createdDate: DateTime.now()));
        } else {
          List list = [];
          await firestore
              .collection("artists")
              .doc(FirebaseAuthService().getUsername())
              .collection("singles")
              .where('time', isLessThan: listFromDatabase[0]['time'])
              .get()
              .then((querySnapshot) {
            for (var json in querySnapshot.docs) {
              list.add(json.data());
            }
            print(list);
            list = list.reversed.toList();
            for (var item in list) {
              listReturn.insert(0, item);
            }
          });
          box.put(
              "ownSongs",
              Playlist(
                  name: "ownSongs",
                  songs: listReturn,
                  createdDate: DateTime.now()));
        }
      }
    });
   
    } on FirebaseException catch (e) {
      if(e.code=="permission-denied"){
        Functions().showAlertDialog(context, "Databases are close. Please try again later!");
      }else{
        Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
      }
    }catch (e){
      Functions().showAlertDialog(context, "Unexpected error, please try again later or check app update!");
    }
    
    return listReturn;
  }

  Future<void> increaseView(String songId) async {
    await firestore.runTransaction((transaction) async {
      DocumentReference postRef = firestore.collection('songs').doc(songId);
      DocumentSnapshot snapshot = await transaction.get(postRef);
      int likesCount = snapshot.get("views");
      transaction.update(postRef, {'views': likesCount + 1});
    });
  }
}
