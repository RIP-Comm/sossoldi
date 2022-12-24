import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

//This class can be used when we need to draw a line chart with one or two lines
class LineChartWidget extends StatefulWidget {
  final line1Data; //this should be a list of Flspot(x,y)
  final colorLine1Data;

  final line2Data; //this should be a list of Flspot(x,y), if you only need one just put an empty list
  final colorLine2Data;

  //These will be used to determine the max value of the chart in order to get the right visualization of the data
  final maxY;
  final minY;

  //Contains the number of days of the month
  final maxDays; 

  final colorBackground;
  const LineChartWidget({
    super.key, 
    required this.line1Data, 
    required this.colorLine1Data, 
    required this.line2Data,
    required this.colorLine2Data, 
    required this.colorBackground,
    required this.maxY,
    required this.minY,
    required this.maxDays,
    });

  @override
  State<LineChartWidget> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartWidget> {
  _LineChartSample2State();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
                padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
              ),
              child: LineChart(
                mainData(),
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
      fontSize: 9,
    );
    Widget text;
    switch (value.toInt()) {
      case 6:
        text = Text('8 Nov', style: style);
        break;
      case 16:
        text = Text('15 Nov', style: style);
        break;
      case 23:
        text = Text('22 Nov', style: style);
        break;
      case 6:
        text = Text('30 Nov', style: style);
        break;
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
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(
                border: const Border(bottom: BorderSide(color: Colors.grey, width: 1.0, style: BorderStyle.solid))
                ),
      minX: 0,
      maxX: widget.maxDays-1,
      minY: widget.minY,
      maxY: widget.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.line1Data,
          isCurved: true,
          barWidth: 1.5,
          isStrokeCapRound: true,
          color: widget.colorLine1Data,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: widget.colorLine1Data.withOpacity(0.3)
          ),
        ),
        LineChartBarData(
          spots: widget.line2Data,
          isCurved: true,
          barWidth: 1,
          isStrokeCapRound: true,
          color: widget.colorLine2Data,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }
}