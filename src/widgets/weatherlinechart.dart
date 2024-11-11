import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LineChartSample2 extends StatefulWidget {
  final Map<String, Map<String, Map<String, dynamic>>> organizedUSFData;
  final Map<String, Map<String, Map<String, dynamic>>> organizedVFData;

  const LineChartSample2(
      {required this.organizedUSFData, required this.organizedVFData});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];

  bool showAvg = false;
  List<String> chartxname = [];
  List<FlSpot>? spots;
  double? chart_maxy;
  double? chart_miny;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 30,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.lato(
      //fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Colors.black87

    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(chartxname[0], style: style);
        break;
      case 1:
        text = Text(chartxname[1], style: style);
        break;
      case 2:
        text = Text(chartxname[2], style: style);
        break;
      case 3:
        text = Text(chartxname[3], style: style);
        break;
      case 4:
        text = Text(chartxname[4], style: style);
        break;
      case 5:
        text = Text(chartxname[5], style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case -20:
        text = '-20°C';
        break;
      case -15:
        text = '-15°C';
        break;
      case -10:
        text = '-10°C';
        break;
      case -5:
        text = '-5°C';
        break;
      case 0:
        text = '0°C';
        break;
      case 5:
        text = '5°C';
        break;
      case 10:
        text = '10°C';
        break;
      case 15:
        text = '15°C';
        break;
      case 20:
        text = '20°C';
        break;
      case 25:
        text = '25°C';
        break;
      case 30:
        text = '30°C';
        break;
      case 35:
        text = '35°C';
        break;
      case 40:
        text = '40°C';
        break;
      case 45:
        text = '45°C';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: GoogleFonts.lato(
            fontSize: 14.0, color: Colors.black87),
        textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    spots = generateSpotsUSFData(widget.organizedUSFData);
    double maxtemp =
        spots!.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    double mintemp =
        spots!.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    chart_maxy = (maxtemp).ceilToDouble();
    chart_miny = (mintemp).floorToDouble();
    print("차트 minmaxy");
    print(chart_miny);
    print(chart_maxy);
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return bottomTitleWidgets(value, meta);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 5,
      minY: chart_miny! - 3,
      maxY: chart_maxy! + 3,
      lineBarsData: [
        LineChartBarData(
          spots: spots!,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //spot 데이터 정리
  List<FlSpot> generateSpotsUSFData(
      Map<String, Map<String, Map<String, dynamic>>> data) {
    List<FlSpot> spots = [];
    double x = 0;
    data.forEach((date, hourlyData) {
      hourlyData.forEach((hour, details) {
        double y = double.parse(details['T1H']);
        spots.add(FlSpot(x++, y));
        chartxname.add(hour);
      });
    });
    return spots;
  }
}
