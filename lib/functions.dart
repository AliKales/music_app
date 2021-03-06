import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:free_music/colors.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class Functions {
  Future<DateTime> getCurrentGlobalTime(context) async {
    DateTime now; 
    try {
      Response response = await get(
          Uri.parse("http://worldtimeapi.org/api/timezone/Europe/Istanbul"));
      Map worldData = jsonDecode(response.body);
      now = DateTime(
        int.parse(worldData['datetime'].substring(0, 4)),
        int.parse(worldData['datetime'].substring(5, 7)),
        int.parse(worldData['datetime'].substring(8, 10)),
        int.parse(worldData['datetime'].substring(11, 13)),
        int.parse(worldData['datetime'].substring(14, 16)),
        int.parse(worldData['datetime'].substring(17, 19)),
      );
    } catch (e) {
      now = DateTime.now();
      Functions().showAlertDialog(context,
          "Unexpected error, please try again later or check app update!");
    }

    return now;
  }

  void showToast(String text,context) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));
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
                  await canLaunch(
                          "https://play.google.com/store/apps/details?id=com.caroby.caroby_share_your_music")
                      .then((value) {
                    if (value) {
                      launch(
                          "https://play.google.com/store/apps/details?id=com.caroby.caroby_share_your_music");
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
