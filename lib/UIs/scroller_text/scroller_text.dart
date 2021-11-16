import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ScrollerText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Alignment alignment;

  const ScrollerText({Key? key, required this.text,required this.textStyle, required this.alignment}) : super(key: key);

  @override
  _ScrollerTextState createState() => _ScrollerTextState();
}

class _ScrollerTextState extends State<ScrollerText> {
  final scrollDirection = Axis.horizontal;

  AutoScrollController controller = AutoScrollController();

  int itemCounter = 1;

  double paddingRight = 0.0;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildScrollerText();
  }

  ListView buildScrollerText() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: scrollDirection,
      controller: controller,
      children: <Widget>[
        ...List.generate(itemCounter, (index) {
          return AutoScrollTag(
            key: ValueKey(index),
            controller: controller,
            index: index,
            child: Container(
              margin: EdgeInsets.only(right: paddingRight),
              height: double.maxFinite,
              color: Colors.black.withOpacity(0.0),
              child: Align(
                alignment: widget.alignment,
                child: Text(
                  widget.text,
                  style: widget.textStyle,
                ),
              ),
            ),
            highlightColor: Colors.black.withOpacity(0.1),
          );
        }),
      ],
    );
  }

  Future _scrollToIndex() async {
    if (controller.position.maxScrollExtent != 0.0) {
      setState(() {
        paddingRight = 100.0;
        itemCounter = 2;
      });
      await Future.delayed(const Duration(seconds: 3));
      try {
        await controller
            .scrollToIndex(1,
                preferPosition: AutoScrollPosition.begin,
                duration: const Duration(seconds: 10))
            .whenComplete(() {
          controller.jumpTo(0);
          _scrollToIndex();
        });
      } catch (e) {}
    }
  }
}
