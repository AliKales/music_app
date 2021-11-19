import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:free_music/colors.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class Functions {
  Future<DateTime> getCurrentGlobalTime() async {
    Response response = await get(
        Uri.parse("http://worldtimeapi.org/api/timezone/Europe/Istanbul"));
    Map worldData = jsonDecode(response.body);
    DateTime now = DateTime(
      int.parse(worldData['datetime'].substring(0, 4)),
      int.parse(worldData['datetime'].substring(5, 7)),
      int.parse(worldData['datetime'].substring(8, 10)),
      int.parse(worldData['datetime'].substring(11, 13)),
      int.parse(worldData['datetime'].substring(14, 16)),
      int.parse(worldData['datetime'].substring(17, 19)),
    );
    return now;
  }

  void showToast(String text, ToastGravity? toastGravity) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: toastGravity ?? ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void showAlertDialog(context, String content) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: thirdColor,
          title: const Text(
            "Something went wrong :/",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            content,
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            Visibility(
              visible: content ==
                  "Unexpected error, please try again later or check app update!",
              child: OutlinedButton(
                onPressed: () async {                   
                  Navigator.pop(context);
                  await canLaunch("https://play.google.com/store/apps/details?id=com.caroby.caroby_share_your_music").then((value) {
                    if(value){
                      launch("https://play.google.com/store/apps/details?id=com.caroby.caroby_share_your_music");
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: fourthColor), elevation: 0),
                child: const Text(
                  "Check",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(primary: fourthColor, elevation: 0),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}
