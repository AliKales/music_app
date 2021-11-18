import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

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

  void showToast(String text , ToastGravity? toastGravity){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: toastGravity?? ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<bool> checkInternetConnection() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }else{
      return true;
    }
  }
}
