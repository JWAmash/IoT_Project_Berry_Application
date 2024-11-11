import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';

//import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project_berry/src/widgets/dust_barchart.dard.dart';
import 'package:iot_project_berry/src/widgets/dust_statuscircle.dart';

class ScreenBerry extends StatefulWidget {
  // final dynamic parseWeatherUSNData;
  // final dynamic parseWeatherUSFData;
  // final dynamic parseWeatherVFData;

  ScreenBerry(// {this.parseWeatherUSNData,
      // this.parseWeatherUSFData,
      // this.parseWeatherVFData}
      );

  @override
  State<ScreenBerry> createState() => _ScreenBerryState();
}

class _ScreenBerryState extends State<ScreenBerry> {
  String documentData = "Loading...";

  int dustWidgetindex = 0;
  List<Map<String, dynamic>> pmData = [
    // {'time': '12:00', 'dustValue': 35},
    // {'time': '13:00', 'dustValue': 55},
    // {'time': '14:00', 'dustValue': 120},
    // {'time': '15:00', 'dustValue': 80},
    // {'time': '16:00', 'dustValue': 50},
    // {'time': '17:00', 'dustValue': 35},
    // {'time': '18:00', 'dustValue': 55},
    // {'time': '19:00', 'dustValue': 120},
    // {'time': '20:00', 'dustValue': 80},
    // {'time': '21:00', 'dustValue': 50},
    // {'time': '22:00', 'dustValue': 35},
    // {'time': '23:00', 'dustValue': 55},
    // {'time': '24:00', 'dustValue': 120},
    // {'time': '00:00', 'dustValue': 80},
    // {'time': '01:00', 'dustValue': 70},
  ];
  List<Map<String, dynamic>> fpmData = [];
  List<Map<String, dynamic>> tempData = [];
  List<Map<String, dynamic>> humData = [];

  @override
  void initState() {
    super.initState();
    DateTime targetDate = DateTime(2024, 10, 27);
    fetchData(targetDate);
    // print(widget.parseWeatherVFData);
    // print(widget.parseWeatherUSFData);
  }

  Future<void> fetchData(DateTime date) async {
    try {
      // 날짜 기반 문서를 가져오기 위해 오늘 날짜를 포맷
      String datePrefix =
          "sensor_data_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_";

      // Firestore 컬렉션에서 하루 동안의 모든 문서 가져오기
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('data')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: datePrefix)
          .where(FieldPath.documentId, isLessThan: "${datePrefix}24")
          .get();

      List<String> pm10MaxList = [];
      List<String> pm10AvgList = [];
      List<String> pm25MaxList = [];
      List<String> pm25AvgList = [];
      List<String> humMaxList = [];
      List<String> humAvgList = [];
      List<String> tempMaxList = [];
      List<String> tempAvgList = [];
      List<String> timestampList = [];

      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // pm10MaxList.add(data.containsKey('PM 10.0 최대값') ? data['PM 10.0 최대값'].toString() : "데이터 없음");
        // pm10AvgList.add(data.containsKey('PM 10.0 평균') ? data['PM 10.0 평균'].toString() : "데이터 없음");
        // pm25MaxList.add(data.containsKey('PM 2.5 최대값') ? data['PM 2.5 최대값'].toString() : "데이터 없음");
        // pm25AvgList.add(data.containsKey('PM 2.5 평균') ? data['PM 2.5 평균'].toString() : "데이터 없음");
        // humMaxList.add(data.containsKey('습도 최대값') ? data['습도 최대값'].toString() : "데이터 없음");
        // humAvgList.add(data.containsKey('습도 평균') ? data['습도 평균'].toString() : "데이터 없음");
        // tempMaxList.add(data.containsKey('온도 최대값') ? data['온도 최대값'].toString() : "데이터 없음");
        // tempAvgList.add(data.containsKey('온도 평균') ? data['온도 평균'].toString() : "데이터 없음");
        //
        // if (data.containsKey('timestamp')) {
        //   Timestamp timestamp = data['timestamp'];
        //   DateTime dateTime = timestamp.toDate();
        //   String formattedDate = "${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분 ${dateTime.second}초";
        //   timestampList.add(formattedDate);
        // } else {
        //   timestampList.add("데이터 없음");
        // }

        // 타임스탬프가 있는지 확인
        if (data.containsKey('timestamp')) {
          Timestamp timestamp = data['timestamp'];
          DateTime dateTime = timestamp.toDate();
          String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
          // PM 2.5 평균 값이 있는지 확인
          if (data.containsKey('PM 2.5 평균')) {
            double fpm25Avg = data['PM 2.5 평균'];
            // 시간과 PM 2.5 평균 값을 testdata 리스트에 추가
            fpmData.add({
              'time': formattedTime,
              'Value': fpm25Avg,
            });
          }
          if (data.containsKey('PM 10.0 평균')) {
            double pmAvg = data['PM 10.0 평균'];
            // 시간과 PM 2.5 평균 값을 testdata 리스트에 추가
            pmData.add({
              'time': formattedTime,
              'Value': pmAvg,
            });
          }
          if (data.containsKey('온도 평균')) {
            double tempAvg = data['온도 평균'];
            // 시간과 PM 2.5 평균 값을 testdata 리스트에 추가
            tempData.add({
              'time': formattedTime,
              'Value': tempAvg,
            });
          }
          if (data.containsKey('습도 평균')) {
            double humAvg = data['습도 평균'];
            // 시간과 PM 2.5 평균 값을 testdata 리스트에 추가
            humData.add({
              'time': formattedTime,
              'Value': humAvg,
            });
          }
        }
      }

      setState(() {
        documentData = "PM 10.0 최대값 리스트: $pm10MaxList\n"
            "PM 10.0 평균 리스트: $pm10AvgList\n"
            "PM 2.5 최대값 리스트: $pm25MaxList\n"
            "PM 2.5 평균 리스트: $pm25AvgList\n"
            "습도 최대값 리스트: $humMaxList\n"
            "습도 평균 리스트: $humAvgList\n"
            "온도 최대값 리스트: $tempMaxList\n"
            "온도 평균 리스트: $tempAvgList\n"
            "timestamp 리스트: $timestampList";
      });
      print('미세$pmData');
      print('초미세$fpmData');
      print('온도$tempData');
      print('습도$humData');
      
    } catch (e) {
      setState(() {
        documentData = "Error fetching data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final String temptopic = "berry/home/temperature";
    final String pm = "pm10";
    final String fpm = "pm2.5";
    return Scaffold(
        appBar: AppBar(
          title: Text('스마트 스피커 베리'),
        ),
        body: Container(
          child: Stack(children: [
            Container(
              color: Colors.blue[100],
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(children: [
                Column(
                  children: [
                    Text(
                      '실내 미세먼지 현황',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Divider(
                      height: 10,
                      thickness: 1.0,
                      color: Colors.black12,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: BlocBuilder<MqttBloc, MqttState>(
                                  builder: (context, mqttState) {
                                    if (mqttState is MqttDisconnected) {
                                      return _NoDataCircularProgressIndicator();
                                    } else if (mqttState is MqttConnected) {
                                      if ((mqttState.messages[temptopic] !=
                                                  null &&
                                              mqttState.messages[temptopic]![
                                                      pm] ==
                                                  null) ||
                                          (mqttState.messages[temptopic] ==
                                              null)) {
                                        return _NoDataCircularProgressIndicator();
                                      } else {
                                        return DustStatusCircle(
                                            DustStatus: mqttState
                                                .messages[temptopic]![pm],
                                            isFineDust: false);
                                      }
                                    } else {
                                      return _NoDataCircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Text('미세먼지')
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: BlocBuilder<MqttBloc, MqttState>(
                                  builder: (context, mqttState) {
                                    if (mqttState is MqttDisconnected) {
                                      return _NoDataCircularProgressIndicator();
                                    } else if (mqttState is MqttConnected) {
                                      if ((mqttState.messages[temptopic] !=
                                                  null &&
                                              mqttState.messages[temptopic]![
                                                      fpm] ==
                                                  null) ||
                                          (mqttState.messages[temptopic] ==
                                              null)) {
                                        return _NoDataCircularProgressIndicator();
                                      } else {
                                        return DustStatusCircle(
                                            DustStatus: mqttState
                                                .messages[temptopic]![fpm],
                                            isFineDust: false);
                                      }
                                    } else {
                                      return _NoDataCircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Text('초미세먼지')
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '실외 미세먼지 현황',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Divider(
                      height: 10,
                      thickness: 1.0,
                      color: Colors.black12,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: DustStatusCircle(
                                      DustStatus: 60, isFineDust: false)),
                              Text('미세먼지')
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: DustStatusCircle(
                                    DustStatus: 90, isFineDust: true),
                              ),
                              Text('초미세먼지')
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 400,
                  child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          TabBar(tabs: [
                            Tab(
                              text: 'PM 2.5',
                            ),
                            Tab(
                              text: 'PM 10',
                            ),
                            Tab(
                              text: '실내 온도',
                            ),
                            Tab(
                              text: '실내 습도',
                            )
                          ]),
                          Expanded(
                              child: TabBarView(children: [
                            Column(children: [
                              SizedBox(
                                height: 20,
                              ),
                              DustBarChart(
                                dustData: pmData,
                                title: '미세먼지',category: '미세먼지',
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 20,
                              ),
                              DustBarChart(
                                dustData: fpmData,
                                title: '초미세먼지',category: '초미세먼지',
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 20,
                              ),
                              DustBarChart(
                                dustData: tempData,
                                title: '온도',
                                category: '온도',
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 20,
                              ),
                              DustBarChart(
                                dustData: humData,
                                title: '습도',
                                category: '습도',
                              )
                            ]),
                          ]))
                        ],
                      )),
                ),
                Text(
                  'ScreenA',
                  style: TextStyle(fontSize: 20.0),
                ),
              ]
                  // child: ElevatedButton(
                  //   onPressed: () {Navigator.pop(ctx);},
                  //   child: Text('Go to the First page'),
                  // ),
                  ),
            ),
          ]),
        ));
  }
}

Widget _NoDataCircularProgressIndicator() {
  return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(0),
      //width: MediaQuery.of(context).size.width / 2 - 20,
      //1height: MediaQuery.of(context).size.width / 2 - 20,
      decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      child: Stack(
        children: [Center(child: CircularProgressIndicator())],
      ));
}
