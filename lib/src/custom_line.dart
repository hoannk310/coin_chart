import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'coordinate.dart';
import 'package:collection/collection.dart';

class CustomLine extends CustomPainter {
  CustomLine(this.datas, this.countY,
      {this.topPadding = 40,
      this.bottomPadding = 60,
      this.textStyle = const TextStyle(color: Colors.black)});

  final List<Coordinate> datas;
  final double topPadding;
  final double bottomPadding;
  final TextStyle textStyle;
  final double countY; // number of lines in column y
  double dXCustom = 0;

  double getMaxValueY() {
    final maxValueCurrent = datas.map((e) => e.y).reduce(max);
    final minValueCurrent = datas.map((e) => e.y).reduce(min);
    return (maxValueCurrent + (maxValueCurrent - minValueCurrent) / 4)
        .roundToDouble();
  }

  double getMinValueY() {
    return (datas.map((e) => e.y).reduce(min) / 4).roundToDouble();
  }

  double getMaxValueZ() {
    return (datas.map((e) => e.z).reduce(max)).roundToDouble();
  }

  double mapToCoordinateY(double height, double y, double scaleValueWithHeigh) {
    return height - bottomPadding - (y - getMinValueY()) * scaleValueWithHeigh;
  }

  double mapToCoordinateChartX(double x, double distanceBetweenEachElementX) {
    return (x - getMinValueX()) * distanceBetweenEachElementX;
  }

  double mapToCoordinateDataX(double x, double distanceBetweenEachElementX) {
    return x / distanceBetweenEachElementX + getMinValueX();
  }

  double getMinValueX() {
    return (datas.map((e) => e.x).reduce(min));
  }

  double getMaxValueX() {
    return (datas.map((e) => e.x).reduce(max));
  }

  ui.TextStyle maptoUITextStyle(TextStyle textStyle) {
    return ui.TextStyle(
        color: textStyle.color,
        fontFamily: textStyle.fontFamily,
        fontSize: textStyle.fontSize,
        height: textStyle.height,
        fontWeight: textStyle.fontWeight,
        textBaseline: textStyle.textBaseline,
        background: textStyle.background,
        shadows: textStyle.shadows,
        foreground: textStyle.foreground,
        wordSpacing: textStyle.wordSpacing,
        decoration: textStyle.decoration,
        decorationColor: textStyle.decorationColor,
        decorationStyle: textStyle.decorationStyle,
        decorationThickness: textStyle.decorationThickness,
        fontFamilyFallback: textStyle.fontFamilyFallback,
        letterSpacing: textStyle.letterSpacing,
        leadingDistribution: textStyle.leadingDistribution,
        locale: textStyle.locale,
        fontFeatures: textStyle.fontFeatures,
        fontStyle: textStyle.fontStyle,
        fontVariations: textStyle.fontVariations);
  }

  double getTextWidth() {
    final textSpan = TextSpan(
      text: '${getMaxValueY()}',
      style: TextStyle(fontSize: textStyle.fontSize, color: Colors.white),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    return tp.width + 8;
  }

  double getTextColumnWidth() {
    final textSpan = TextSpan(
      text: '${getMaxValueZ()}',
      style: TextStyle(fontSize: textStyle.fontSize, color: Colors.white),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    return tp.width + 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double maxValueY = getMaxValueY();
    final double minValueY = getMinValueY();
    final double scaleValueWithHeigh =
        (size.height - bottomPadding - topPadding) / (maxValueY - minValueY);

    final double distanceBetweenEachElementX =
        (size.width - getTextWidth()) / (getMaxValueX() - getMinValueX());
    //Draw columm
    final double spacingX =
        (size.width - getTextWidth()) / (datas.length.toDouble() - 1);
    final double spacingY =
        (size.height - topPadding - bottomPadding) / (countY - 1);
    final columnWidth = spacingX * (8 / 10);
    final borderRadius = BorderRadius.circular(2.0);
    final maxColumnValue = datas.map((e) => e.z).reduce(max);
    final heightScale = (spacingY / 1) / maxColumnValue;
    drawChartColumnHighlight(canvas, size, heightScale,
        distanceBetweenEachElementX, columnWidth, borderRadius);
    drawLine(canvas, size, distanceBetweenEachElementX);
    drawCircleAndTextValue(
        canvas, size, distanceBetweenEachElementX, scaleValueWithHeigh);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void updateLinePosition(Offset newPosition) {
    dXCustom = newPosition.dx;
  }

  Coordinate getApproximateCoordinate(Coordinate touchCoordinate) {
    int index = lowerBound(datas, touchCoordinate,
        compare: (p0, p1) => p0.x.compareTo(p1.x));
    if (index == 0) {
      return datas[index];
    }
    if (index > datas.length - 1) {
      return datas.last;
    }
    final distanceAtIndex = (datas[index].x - touchCoordinate.x).abs();
    final distanceAtIndexMinusOne =
        (datas[index - 1].x - touchCoordinate.x).abs();
    return distanceAtIndex < distanceAtIndexMinusOne
        ? datas[index]
        : datas[index - 1];
  }

  void drawLine(Canvas canvas, Size size, double distanceBetweenEachElementX) {
    var paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const dashWidth = 5;
    const dashSpace = 5;
    double startY = 0;
    final approximateCoordinate = getApproximateCoordinate(Coordinate(
        mapToCoordinateDataX(dXCustom, distanceBetweenEachElementX), 0, 0));
    final valueX = mapToCoordinateChartX(
        approximateCoordinate.x, distanceBetweenEachElementX);

    while (startY < size.height - bottomPadding) {
      canvas.drawLine(
        Offset(valueX, startY),
        Offset(valueX, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  void drawCircleAndTextValue(Canvas canvas, Size size,
      double distanceBetweenEachElementX, double scaleValueWithHeigh) {
    final circleBorderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final approximateCoordinate = getApproximateCoordinate(Coordinate(
        mapToCoordinateDataX(dXCustom, distanceBetweenEachElementX), 0, 0));
    final valueX = mapToCoordinateChartX(
        approximateCoordinate.x, distanceBetweenEachElementX);
    final valueY = mapToCoordinateY(
        size.height, approximateCoordinate.y, scaleValueWithHeigh);

    Offset circleCenter = Offset(valueX, valueY);
    canvas.drawCircle(circleCenter, 4, circleBorderPaint);
    Offset circleCenter2 = Offset(valueX, valueY);
    canvas.drawCircle(circleCenter2, 1.5, innerCirclePaint);

    final ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center));
    paragraphBuilder.pushStyle(maptoUITextStyle(textStyle));
    paragraphBuilder.addText('${approximateCoordinate.y}');
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: getTextWidth()));
    Offset textCenter =
        Offset(valueX - paragraph.width / 2, (valueY - paragraph.height - 10));
    canvas.drawParagraph(paragraph, textCenter);
  }

  void drawChartColumnHighlight(
      Canvas canvas,
      Size size,
      double heightScale,
      double distanceBetweenEachElementX,
      double columnWidth,
      BorderRadius borderRadius) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final approximateCoordinate = getApproximateCoordinate(Coordinate(
        mapToCoordinateDataX(dXCustom, distanceBetweenEachElementX), 0, 0));
    final valueX = (approximateCoordinate.x == datas.first.x)
        ? mapToCoordinateChartX(
            approximateCoordinate.x, distanceBetweenEachElementX)
        : mapToCoordinateChartX(
                approximateCoordinate.x, distanceBetweenEachElementX) -
            columnWidth / 2;

    final columnHeight = approximateCoordinate.z.toDouble() * heightScale;

    final startY = size.height - bottomPadding - columnHeight;

    final rRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
          valueX,
          startY,
          (approximateCoordinate.x == datas.first.x) ||
                  (approximateCoordinate.x == datas.last.x)
              ? columnWidth / 2
              : columnWidth,
          columnHeight),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    canvas.drawRRect(rRect, paint);

    final ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center));

    paragraphBuilder.pushStyle(maptoUITextStyle(textStyle));

    paragraphBuilder.addText('${approximateCoordinate.z}');
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: getTextColumnWidth()));

    Offset textCenter =
        Offset(valueX - paragraph.width / 2, (startY - paragraph.height - 10));

    // canvas.drawParagraph(paragraph, textCenter);
  }
}
