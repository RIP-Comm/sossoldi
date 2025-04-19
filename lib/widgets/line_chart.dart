import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Period { month, year }

//This class can be used when we need to draw a line chart with one or two lines
class LineChartWidget extends StatefulWidget {
  final List<FlSpot> lineData; // this should be a list of Flspot(x,y)
  final Color? lineColor;

  final List<FlSpot> line2Data; // this should be a list of Flspot(x,y)
  final Color? line2Color;

  final bool enableGapFilling;

  // Used to decide the bottom label
  final Period period;
  final int currentMonthDays =
      DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month);
  final int nXLabel = 10;
  final double minY;

  final Color? colorBackground;

  LineChartWidget({
    super.key,
    required List<FlSpot> lineData,
    this.lineColor,
    List<FlSpot> line2Data = const [],
    this.line2Color,
    this.colorBackground,
    this.enableGapFilling = true,
    this.period = Period.month,
    int nXLabel = 10,
    double? minY,
  })  : lineData = enableGapFilling ? fillGaps(lineData) : lineData,
        line2Data = enableGapFilling ? fillGaps(line2Data) : line2Data,
        minY = minY ?? calculateMinY(lineData, line2Data);

  static double calculateMinY(List<FlSpot> line1Data, List<FlSpot> line2Data) {
    if (line1Data.isEmpty && line2Data.isEmpty) {
      return 0;
    }

    return [...line1Data, ...line2Data].map((e) => e.y).reduce(min);
  }

  static List<FlSpot> fillGaps(List<FlSpot> lineData) {
    if (lineData.isEmpty) return [];

    List<FlSpot> filledData = [];
    double lastY = lineData.first.y;

    for (int i = 0; i <= lineData.last.x.toInt(); i++) {
      if (lineData.any((spot) => spot.x == i)) {
        lastY = lineData.firstWhere((spot) => spot.x == i).y;
        filledData.add(FlSpot(i.toDouble(), lastY));
      } else {
        filledData.add(FlSpot(i.toDouble(), lastY));
      }
    }

    return filledData;
  }

  @override
  State<LineChartWidget> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartWidget> {
  _LineChartSample2State();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.colorBackground ?? themeData.colorScheme.tertiary,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Builder(
                builder: (context) {
                  if (widget.lineData.length < 2 &&
                      widget.line2Data.length < 2) {
                    return Center(
                      child: Text(
                        "We are sorry but there is not\nenough data to make the graph...",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    );
                  }
                  return LineChart(
                    mainData(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final ThemeData themeData = Theme.of(context);
    Color lineColor = widget.lineColor ?? themeData.colorScheme.primary;
    final style = TextStyle(
      color: lineColor,
      fontWeight: FontWeight.normal,
      fontSize: 8,
    );
    Widget text;
    switch (widget.period) {
      case Period.year:
        switch (value.toInt()) {
          case 1:
            text = Text('Feb', style: style);
            break;
          case 2:
            text = Text('Mar', style: style);
            break;
          case 3:
            text = Text('Apr', style: style);
            break;
          case 4:
            text = Text('May', style: style);
            break;
          case 5:
            text = Text('Jun', style: style);
            break;
          case 6:
            text = Text('Jul', style: style);
            break;
          case 7:
            text = Text('Aug', style: style);
            break;
          case 8:
            text = Text('Sep', style: style);
            break;
          case 9:
            text = Text('Oct', style: style);
            break;
          case 10:
            text = Text('Nov', style: style);
            break;
          default:
            text = Text('', style: style);
            break;
        }
        break;
      case Period.month:
        int step = (widget.currentMonthDays / widget.nXLabel).round();
        if (value.toInt() % step == 1 &&
            value.toInt() != widget.currentMonthDays) {
          text = Text((value + 1).toStringAsFixed(0), style: style);
        } else {
          text = Text('', style: style);
        }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    final ThemeData themeData = Theme.of(context);
    Color lineColor = widget.lineColor ?? themeData.colorScheme.primary;
    Color line2Color = widget.line2Color ?? themeData.disabledColor;

    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          bool allSameX = spotIndexes.toSet().length == 1;

          if (!allSameX) {
            return [];
          }
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              const FlLine(
                color: Colors.blueGrey,
                strokeWidth: 2,
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.grey,
                    strokeWidth: 2,
                    strokeColor: Colors.blueGrey,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            bool allSameX = touchedBarSpots.map((e) => e.x).toSet().length == 1;

            if (!allSameX || touchedBarSpots.isEmpty) {
              return [];
            }

            double x = touchedBarSpots[0].x;
            DateTime date = widget.period == Period.month
                ? DateTime(
                    DateTime.now().year, DateTime.now().month, (x + 1).toInt())
                : DateTime(DateTime.now().year, (x + 1).toInt(), 1);
            String dateFormat = widget.period == Period.month
                ? DateFormat(DateFormat.ABBR_MONTH_DAY).format(date)
                : DateFormat(DateFormat.ABBR_MONTH).format(date);

            LineTooltipItem first = LineTooltipItem(
              '$dateFormat \n\n',
              TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: touchedBarSpots[0].y.toString(),
                  style: TextStyle(
                    color: line2Color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );

            var others = touchedBarSpots.sublist(1).map((barSpot) {
              final flSpot = barSpot;

              return LineTooltipItem(
                '',
                const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: flSpot.y.toString(),
                    style: TextStyle(
                      color: lineColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }).toList();

            return [first, ...others];
          },
        ),
      ),

      borderData: FlBorderData(
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      minX: 0,
      // if year display 12 month, if month display the number of days in it
      maxX: widget.period == Period.year ? 11 : widget.currentMonthDays - 1,
      minY: widget.minY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.lineData,
          isCurved: true,
          curveSmoothness: 0.15,
          barWidth: 1.5,
          isStrokeCapRound: true,
          color: lineColor,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withValues(alpha: 0.2),
          ),
        ),
        LineChartBarData(
          spots: widget.line2Data,
          isCurved: true,
          curveSmoothness: 0.15,
          barWidth: 1,
          isStrokeCapRound: true,
          color: line2Color,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}
