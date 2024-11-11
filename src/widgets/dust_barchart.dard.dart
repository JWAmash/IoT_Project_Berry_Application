import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iot_project_berry/src/config/palette.dart';

class DustBarChart extends StatefulWidget {
  @override
  final List<Map<String, dynamic>> dustData;
  final String title;
  final String category;

  const DustBarChart(
      {super.key, required this.dustData, required this.title, required this.category});

  State<DustBarChart> createState() => _DustBarChartState();
}

class _DustBarChartState extends State<DustBarChart> {
  // 예시 데이터: 시간과 미세먼지 값이 들어있는 리스트

  // 미세먼지 값에 따라 색상을 변경하는 함수
  //PM 미세먼지 FPM 초미세먼지

  Color getColor(double value, String category) {
    if (category == '미세먼지') {
      return getColorByPMValue(value);
    } else if (category == '초미세먼지') {
      return getColorByFPMValue(value);
    } else if (category == '온도') {
      return getColorByTempValue(value);
    } else if (category == '습도') {
      return getColorByHumValue(value);
    } else {
      return Colors.grey; // 알 수 없는 카테고리일 경우 기본값
    }
  }

  Color getColorByFPMValue(double value) {
    if (value > 100) {
      return Palette.dustColorVeryBad;
    } else if (value > 50) {
      return Palette.dustColorBad;
    } else if (value > 15) {
      return Palette.dustColorModerate;
    } else if (value >= 0) {
      return Palette.dustColorGood;
    } else {
      return Colors.white;
    }
  }

  Color getColorByPMValue(double value) {
    if (value > 150) {
      return Palette.dustColorVeryBad;
    } else if (value > 80) {
      return Palette.dustColorBad;
    } else if (value > 50) {
      return Palette.dustColorModerate;
    } else if (value >= 0) {
      return Palette.dustColorGood;
    } else {
      return Colors.white;
    }
  }

  Color getColorByTempValue(double value) {
    if (value >= 28) {
      return Palette.tempColor1;

    }
    // 매우 차가운 상태
    else if (value >= 23) {
      return Palette.tempColor2;
    } // 찬 상태
    else if (value >= 20) {
      return Palette.tempColor3;
    }
    else if (value >= 17) {
      return Palette.tempColor4;
    }
    else if (value >= 12) {
      return Palette.tempColor5;
    }
    else if (value >= 9) {
      return Palette.tempColor6;
    }
    else if (value >= 5) {
      return Palette.tempColor7;
    }
    else {
      return Palette.tempColor8;
    } // 매우 뜨거운 상태
  }

  Color getColorByHumValue(double value) {
    if (value < 30) {
      return Colors.red;
    } // 매우 건조한 상태
    else if (value < 50) {
      return Colors.green;
    } // 건조한 상태
    else if (value < 70) {
      return Colors.lightBlue;
    } // 쾌적한 상태
    else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dustData = widget.dustData;
    String category = widget.category;
    return Container(
      padding: EdgeInsets.only(right: 30),
      height: 280,
      child: BarChart(
        BarChartData(
            barGroups: dustData
                .asMap()
                .entries
                .map((entry) {
              int index = entry.key;
              var data = entry.value;
              return BarChartGroupData(
                  x: index, // X축: 데이터 인덱스
                  barRods: [
              BarChartRodData(
              toY: data['Value'].toInt().toDouble(),
              // Y축: 미세먼지 값
              color: getColor(data['Value'], category),
              // 미세먼지 값에 따른 색상
              width: 16, // 막대 너비
              ),
              ],
              showingTooltipIndicators: [
              0
              ]);
            }).toList(),
            barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.only(left: 4, right: 4),
                    tooltipMargin: 5,
                    getTooltipItem: (BarChartGroupData group, int groupIndex,
                        BarChartRodData rod, int rodIndex) {
                      var data = widget.dustData[groupIndex];
                      return BarTooltipItem(
                          rod.toY.toInt().toString(),
                          TextStyle(
                              color: getColor(data['Value'],category),
                              fontWeight: FontWeight.bold));
                    },
                    getTooltipColor: (BarChartGroupData group) {
                      //툴팁 배경 색
                      return Colors.transparent;
                    })),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 30,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index % 2 == 0) {
                      return Text(dustData[index]['time']); // X축: 시간
                    }
                    return Text('');
                  },
                ),
              ),
              rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                // axisNameSize: 30,
                // axisNameWidget: Text(widget.title),
                  sideTitles: SideTitles(showTitles: false)
              ),
            ),
            borderData: FlBorderData(
                show: true,
                border: Border(
                    left: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    right: BorderSide.none,
                    top: BorderSide.none)),
            gridData: FlGridData(show: false),
            alignment: BarChartAlignment.spaceAround,
            maxY: 200),
      ),
    );
  }
}
