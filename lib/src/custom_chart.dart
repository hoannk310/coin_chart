import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'coordinate.dart';

class CustomChart extends CustomPainter {
  CustomChart(this.datas, this.countY,
      {this.topPadding = 40,
      this.bottomPadding = 60,
      this.textStyle = const TextStyle(color: Colors.black)});

  final List<Coordinate> datas;
  final double topPadding;
  final double bottomPadding;
  final int countY; // number of lines in column y
  final TextStyle textStyle;

  double getMaxValueY() {
    final maxValueCurrent = datas.map((e) => e.y).reduce(max);
    final minValueCurrent = datas.map((e) => e.y).reduce(min);
    return (maxValueCurrent + (maxValueCurrent - minValueCurrent) / 4)
        .roundToDouble();
  }

  double getMinValueY() {
    return (datas.map((e) => e.y).reduce(min) / 4).roundToDouble();
  }

  double mapToCoordinateY(double height, double y, double scaleValueWithHeigh) {
    return height - bottomPadding - (y - getMinValueY()) * scaleValueWithHeigh;
  }

  double mapToCoordinateX(double x, double distanceBetweenEachElementX) {
    return ((x - getMinValueX())) * distanceBetweenEachElementX;
  }

  double getMinValueX() {
    return (datas.map((e) => e.x).reduce(min));
  }

  double getMaxValueX() {
    return (datas.map((e) => e.x).reduce(max));
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

  @override
  void paint(Canvas canvas, Size size) {
    final double maxValueY = getMaxValueY();
    final double minValueY = getMinValueY();
    final double spacingY =
        (size.height - topPadding - bottomPadding) / (countY - 1);
    final double valueEachNodeY =
        (maxValueY - minValueY) / (size.height - topPadding - bottomPadding);
    final double scaleValueWithHeigh =
        (size.height - topPadding - bottomPadding) / (maxValueY - minValueY);
    final double spacingX =
        (size.width - getTextWidth()) / (datas.length.toDouble() - 1);
    final double distanceBetweenEachElementX =
        (size.width - getTextWidth()) / (getMaxValueX() - getMinValueX());
    //Draw columm
    final columnWidth = spacingX * (8 / 10);
    final borderRadius = BorderRadius.circular(2.0);
    final maxColumnValue = datas.map((e) => e.z).reduce(max);
    final heightScale = (spacingY / 1) / maxColumnValue;

    fillBackgroundColor(canvas, size);
    fillBackgroundChartColor(canvas, size, spacingX);
    drawValueX(canvas, size, spacingX);
    drawWaveChart(canvas, size, spacingX, scaleValueWithHeigh,
        distanceBetweenEachElementX);
    drawValueYandLine(
        canvas, size, spacingY, maxValueY, minValueY, valueEachNodeY);
    drawChartColumn(canvas, size, heightScale, distanceBetweenEachElementX,
        columnWidth, borderRadius);
  }

  // Set background view
  void fillBackgroundColor(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue.withOpacity(0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // Set background chart
  void fillBackgroundChartColor(
    Canvas canvas,
    Size size,
    double spacingX,
  ) {
    const gradient = LinearGradient(
      colors: [Colors.green, Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    var paint = Paint()
      ..shader = gradient
          .createShader(Rect.fromLTWH(40, 40, size.width / 2, size.height / 2))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(spacingX * (datas.length.toDouble() - 1), 0);
    path.lineTo(
        spacingX * (datas.length.toDouble() - 1), size.height - bottomPadding);
    path.lineTo(0, size.height - bottomPadding);
    path.close();
    canvas.drawPath(path, paint);
  }

  // Draw value x
  void drawValueX(Canvas canvas, Size size, double spacingX) {
    for (double i = 0; i < size.width - getTextWidth(); i = i + spacingX) {
      // Offset startingPoint = Offset(i, 0);
      // Offset endingPoint = Offset(i, size.height - getTextWidth());
      // canvas.drawLine(startingPoint, endingPoint, paint);

      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(textAlign: ui.TextAlign.center));

      paragraphBuilder.pushStyle(maptoUITextStyle(textStyle));

      //  paragraphBuilder.addText(arrayValueX[((i) / spacingX).round() - 1]);
      final ui.Paragraph paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: spacingX));
      canvas.drawParagraph(paragraph,
          Offset(i - paragraph.width / 2, size.height - getTextWidth()));
    }
  }

  // Draw wave chart and fill top color
  void drawWaveChart(Canvas canvas, Size size, double spacingX,
      double scaleValueWithHeigh, double distanceBetweenEachElementX) {
    // Draw wave chart
    var linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Fill top color
    var fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(mapToCoordinateX(datas[0].x, distanceBetweenEachElementX),
        mapToCoordinateY(size.height, datas[0].y, scaleValueWithHeigh));
    for (int i = 0; i < datas.length - 1; i++) {
      Offset startingPoint = Offset(
          mapToCoordinateX(datas[i].x, distanceBetweenEachElementX),
          mapToCoordinateY(size.height, datas[i].y, scaleValueWithHeigh));
      Offset endingPoint = Offset(
          mapToCoordinateX(datas[i + 1].x, distanceBetweenEachElementX),
          mapToCoordinateY(size.height, datas[i + 1].y, scaleValueWithHeigh));
      if (i != 0) {
        path.lineTo(mapToCoordinateX(datas[i].x, distanceBetweenEachElementX),
            mapToCoordinateY(size.height, datas[i].y, scaleValueWithHeigh));
      }
      canvas.drawLine(startingPoint, endingPoint, linePaint);
    }
    path.lineTo(
        mapToCoordinateX(
            datas[datas.length - 1].x, distanceBetweenEachElementX),
        mapToCoordinateY(
            size.height, datas[datas.length - 1].y, scaleValueWithHeigh));

    path.lineTo(spacingX * (datas.length - 1), 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, fillPaint);
  }

  void drawValueYandLine(Canvas canvas, Size size, double spacingY,
      double maxValueY, double minValueY, double valueEachNode) {
    var paint = Paint()
      ..color = Colors.teal.withOpacity(0.2)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    var minValueYTemp = minValueY;

    for (double i = size.height - bottomPadding;
        i >= topPadding - 1;
        i = i - spacingY) {
      Offset startingPoint = Offset(0, i);
      Offset endingPoint = Offset(size.width - 60, i);
      canvas.drawLine(startingPoint, endingPoint, paint);
      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(textAlign: ui.TextAlign.center));

      paragraphBuilder.pushStyle(maptoUITextStyle(textStyle));
      paragraphBuilder.addText('${minValueYTemp.round()}');
      final ui.Paragraph paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: getTextWidth()));
      canvas.drawParagraph(paragraph,
          Offset(size.width - getTextWidth(), i - paragraph.height / 2));
      minValueYTemp += (valueEachNode * spacingY);
    }
  }

  void drawChartColumn(
      Canvas canvas,
      Size size,
      double heightScale,
      double distanceBetweenEachElementX,
      double columnWidth,
      BorderRadius borderRadius) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < datas.length; i++) {
      final columnHeight = datas[i].z.toDouble() * heightScale;
      final startX = i == 0
          ? mapToCoordinateX(datas[i].x, distanceBetweenEachElementX)
          : mapToCoordinateX(datas[i].x, distanceBetweenEachElementX) -
              columnWidth / 2;
      final startY = size.height - bottomPadding - columnHeight;

      final rRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
            startX,
            startY,
            i == 0 || i == (datas.length - 1) ? columnWidth / 2 : columnWidth,
            columnHeight),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );

      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
