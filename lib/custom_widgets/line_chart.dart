import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Period {
  month,
  year
}

//This class can be used when we need to draw a line chart with one or two lines
class LineChartWidget extends StatefulWidget {
  final List<FlSpot> line1Data; //this should be a list of Flspot(x,y)
  final Color colorLine1Data;

  final List<FlSpot> line2Data; //this should be a list of Flspot(x,y), if you only need one just put an empty list
  final Color colorLine2Data;

  // Used to decide the bottom label
  final Period period;
  final int currentMonthDays = DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month);
  final int nXLabel = 10;
  final double minY;
  
  final Color colorBackground;
  LineChartWidget({
    super.key,
    required this.line1Data,
    required this.colorLine1Data,
    required this.line2Data,
    required this.colorLine2Data,
    required this.colorBackground,
    this.period = Period.month,
    int nXLabel = 10,
    double? minY,
  }) : minY = minY ?? calculateMinY(line1Data, line2Data);

  static double calculateMinY(List<FlSpot> line1Data, List<FlSpot> line2Data){
    if (line1Data.isEmpty && line2Data.isEmpty) {
      return 0;
    }

    return [...line1Data, ...line2Data].map((e) => e.y).reduce(min);
  }

  @override
  State<LineChartWidget> createState() => _LineChartSample2State();
  
}

class _LineChartSample2State extends State<LineChartWidget> {
  _LineChartSample2State();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(18),
              ),
              color: widget.colorBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Builder(
                builder: (context) {
                  if(widget.line1Data.length < 2 && widget.line2Data.length < 2){
                    return Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: "We are sorry but there are not\nenough data to make the graph",
                              style: TextStyle(color: Theme.of(context).hintColor),
                            )
                          ]
                          )
                      ),
                    );               }

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
    final style = TextStyle(
      color: widget.colorLine1Data.withOpacity(1.0),
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
        if(value.toInt() % step == 1 && value.toInt() != widget.currentMonthDays){
          text = Text((value + 1).toStringAsFixed(0), style: style,);
        }else{
          text = Text('', style: style);
        }

      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
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

            if(!allSameX){
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
                      strokeColor: Colors.blueGrey
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

            if(!allSameX || touchedBarSpots.isEmpty){
              return [];
            }

            double x = touchedBarSpots[0].x;
            DateTime date = widget.period == Period.month ? 
              DateTime(DateTime.now().year, DateTime.now().month, (x+1).toInt()) :
              DateTime(DateTime.now().year, (x+1).toInt(), 1);
            String dateFormat = widget.period == Period.month ?
              DateFormat(DateFormat.ABBR_MONTH_DAY).format(date) :
              DateFormat(DateFormat.ABBR_MONTH).format(date);

            LineTooltipItem first = LineTooltipItem(
              '$dateFormat \n\n',
              TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: touchedBarSpots[0].y.toString(),
                  style: TextStyle(
                    color: widget.colorLine2Data,
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
                      color: widget.colorLine1Data,
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
          bottom: BorderSide(color: Colors.grey, width: 1.0, style: BorderStyle.solid),
        ),
      ),
      minX: 0,
      maxX: widget.period == Period.year ? 11 : widget.currentMonthDays - 1, // if year display 12 month, if mont display the number of days in the month
      minY: widget.minY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.line1Data,
          isCurved: true,
          barWidth: 1.5,
          isStrokeCapRound: true,
          color: widget.colorLine1Data,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: true, color: widget.colorLine1Data.withOpacity(0.3)),
        ),
        LineChartBarData(
          spots: widget.line2Data,
          isCurved: true,
          barWidth: 1,
          isStrokeCapRound: true,
          color: widget.colorLine2Data,
          dotData: const FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }
}
