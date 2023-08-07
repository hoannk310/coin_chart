import 'package:flutter/material.dart';

import 'coordinate.dart';
import 'custom_chart.dart';
import 'custom_line.dart';

class CoinChart extends StatefulWidget {
  const CoinChart(
      {super.key,
      required this.topPadding,
      required this.bottomPadding,
      required this.textStyleX,
      required this.textStyleToolTip,
      required this.datas,
      required this.heigh,
      required this.width,
      required this.countY});
  final double topPadding;
  final double bottomPadding;
  final double heigh;
  final double width;
  final TextStyle textStyleX;
  final TextStyle textStyleToolTip;
  final List<Coordinate> datas;
  final int countY;

  @override
  State<CoinChart> createState() => _CoinChartState();
}

class _CoinChartState extends State<CoinChart> {
  late CustomLine myCustomPainter;

  bool isShowLine = false;
  bool isPan = false;

  @override
  void initState() {
    myCustomPainter = CustomLine(widget.datas, 6,
        topPadding: widget.topPadding,
        bottomPadding: widget.bottomPadding,
        textStyle: widget.textStyleToolTip);
    super.initState();
  }

  void _handleLongUpdate(LongPressStartDetails details) {
    setState(() {
      isPan = true;
      isShowLine = true;
      myCustomPainter.updateLinePosition(details.localPosition);
    });
  }

  void _handleLongMoveUpdate(LongPressMoveUpdateDetails details) {
    if (isPan) {
      setState(() {
        myCustomPainter.updateLinePosition(details.localPosition);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _handleLongUpdate,
      onLongPressMoveUpdate: _handleLongMoveUpdate,
      onLongPressEnd: (_) {
        setState(() {
          isPan = false;
          isShowLine = false;
        });
      },
      child: SizedBox(
        width: widget.width,
        height: widget.heigh,
        child: CustomPaint(
          painter: CustomChart(
            widget.datas,
            widget.countY,
            topPadding: widget.topPadding,
            bottomPadding: widget.bottomPadding,
            textStyle: widget.textStyleX,
          ),
          foregroundPainter: isShowLine ? myCustomPainter : null,
        ),
      ),
    );
  }
}
