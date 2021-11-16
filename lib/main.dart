import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_music/models/playlist.dart';
import 'package:free_music/models/song.dart';
import 'package:free_music/screens/main_page.dart';
import 'package:free_music/size.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light
  ));
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox('database');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,       
        fontFamily: "RedHatText"
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    gel(context);
    return Container();
  }

  void gel(context) {
    SizeConfig().init(context).then((value) {
      Route route = MaterialPageRoute(builder: (context) => const MainPage());
      Navigator.pushReplacement(context, route);
    });
  }
}
