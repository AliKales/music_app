import 'package:flutter/material.dart';
import 'package:free_music/size.dart';

class CustomAppbar extends StatelessWidget {
  final String? text;
  final List<Widget>? rightWidgets;
  final List<Widget>? leftWidgets;
  final double? padding;
  const CustomAppbar({
    Key? key,
    this.text,
    this.rightWidgets,
    this.leftWidgets, this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.symmetric(horizontal: padding?? 10),
      width: MediaQuery.of(context).size.width,
      height: SizeConfig.safeBlockVertical! * 10.5,
      child: SafeArea(
        child: Row(
          children: [
            Row(
              children: leftWidgets!,
            ),
            Expanded(
              child: Container(
                child: Text(
                  text!,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              children: rightWidgets!,
            )
          ],
        ),
      ),
    );
  }
}
