import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/blocs/airpollution_bloc.dart';
import 'package:iot_project_berry/src/blocs/berrychart_bloc.dart';
import 'package:iot_project_berry/src/blocs/location_state.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/config/palette.dart';
import 'package:iot_project_berry/src/widgets/dust_barchart.dard.dart';
import 'package:iot_project_berry/src/widgets/dust_statuscircle.dart';

class ScreenBerry extends StatefulWidget {
  const ScreenBerry({super.key});

  @override
  State<ScreenBerry> createState() => _ScreenBerryState();
}

class _ScreenBerryState extends State<ScreenBerry> {
  String documentData = "Loading...";
  bool isDataFetched = false;
  late DateTime selectedDate;
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
  double minpm = 0;
  double minfpm = 0;
  double minhum = 0;
  double mintemp = 50;
  double maxpm = 200;
  double maxfpm = 100;
  double maxhum = 0;
  double maxtemp = 0;

  int? inPmTemp;
  int? outPmTemp;
  int? inFpmTemp;
  int? outFpmTemp;

  bool inPmDangerDifference = false;
  bool inFpmDangerDifference = false;
  bool inPmDangerValue = false;
  bool inFpmDangerValue = false;
  bool airDanger = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // 원하는 날짜로 설정
    //selectedDate = DateTime.now();
    final locationState = context.read<LocationBloc>().state;
    context.read<BerryChartDataBloc>().add(BerryChartDataByDate(selectedDate));
    if (locationState is LocationLoaded) {
      // LocationLoaded 상태일 때의 처리
      String region = locationState.region_3depth_name!;

      // 이제 이 값들을 사용하여 AirPollutionBloc에 이벤트를 추가할 수 있습니다
      context.read<AirPollutionBloc>().add(
            AirPollutionTmAddressForSearch(address: region),
          );

      // 나머지 위젯 빌드 로직...
    }
    // DateTime targetDate = DateTime.now();
    // fetchData(targetDate);
    // print(widget.parseWeatherVFData);
    // print(widget.parseWeatherUSFData);
  }

  @override
  Widget build(BuildContext ctx) {
    final String temptopic = "berry/home/temperature";
    final String pm = "pm10";
    final String fpm = "pm2.5";
    DateTime targetDate = DateTime.now();
    return Scaffold(
        appBar: AppBar(
          title: Text('스마트 스피커 베리',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        body: Container(
          child: Stack(children: [
            Container(
              color: Colors.blue[100],
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(children: [
                BlocBuilder<MqttBloc, MqttState>(
                  builder: (context, mqttState) {
                    return BlocBuilder<AirPollutionBloc, AirPollutionState>(
                      builder: (context, airState) {
                        String infoMessage = '';
                        //실외 공기 상태
                        bool pmGood = true;
                        bool fpmGood = true;
                        int pmDist = 0;
                        int fpmDist = 0;
                        if (mqttState is MqttConnected &&
                            airState is AirPollutionLoadedAirData) {
                          print('분기1');

                          //실내 미세먼지 오염수치가 높을때
                          if ((mqttState.messages[temptopic] != null &&
                                  mqttState.messages[temptopic]![pm] != null) &&
                              (mqttState.messages[temptopic] != null)) {
                            //실내 미세먼지 수치를 받아온 상황
                            print('분기2');
                            //실내 먼지 수치에 따른 위험
                            if (mqttState.messages[temptopic]![pm] > 80) {
                              print('실내 먼지가 안좋은 상황');
                              //실내 먼지 안좋음
                              inPmDangerValue = true;
                            } else {
                              print('실내먼지 좋음');
                              //실내 먼지 좋음
                              inPmDangerValue = false;
                            }
                            print('분기3');

                            //실내 실외를 비교하는 상황
                            if (airState.pm != -1) {
                              //실외 미세먼지도 가지고 있을 때 가능
                              if (airState.pm! > 60) {
                                //실외 미세먼지 좋음
                                pmGood = false;
                              }
                              print('실내와 실외를 비교시작');
                              if ((mqttState.messages[temptopic]![pm] -
                                      airState.pm!) >
                                  10) {
                                //두 수치의 값을 비교해서 10보다 크면
                                print('실내실외 차이가 10보다 큼');

                                pmDist = mqttState.messages[temptopic]![pm] -
                                    airState.pm!;
                                inPmDangerDifference = true;
                              } else {
                                print('실내 실외 차이가 10보다 작음');
                                inPmDangerDifference = false;
                              }
                            }
                          } else {
                            //값을 알 수 없을 때
                            inPmDangerDifference = false;
                            inPmDangerValue = false;
                          }

                          print('분기10');
                          //실내 초미세먼지 오염수치가 높을때
                          if ((mqttState.messages[temptopic] != null &&
                                  mqttState.messages[temptopic]![fpm] !=
                                      null) &&
                              (mqttState.messages[temptopic] != null)) {
                            //실내 초미세먼지 수치를 받아온 상황
                            print('분기11');
                            //실내 먼지 수치에 따른 위험
                            if (mqttState.messages[temptopic]![fpm] > 50) {
                              print('실내 초먼지가 안좋은 상황');
                              //실내 먼지 안좋음
                              inFpmDangerValue = true;
                            } else {
                              //실내 먼지 좋음
                              inFpmDangerValue = false;
                            }

                            //실내 실외를 비교하는 상황
                            if (airState.fpm != -1) {
                              //실외 미세먼지도 가지고 있을 때 가능
                              if (airState.fpm! > 30) {
                                //실외 미세먼지 안좋음
                                print('여기인가');
                                fpmGood = false;
                              }
                              print('실내와 실외를 비교시작');
                              if ((mqttState.messages[temptopic]![fpm] -
                                      airState.fpm!) >
                                  10) {
                                //두 수치의 값을 비교해서 10보다 크면
                                print('실내실외 차이가 10보다 큼');
                                fpmDist = mqttState.messages[temptopic]![fpm] -
                                    airState.fpm!;
                                inFpmDangerDifference = true;
                              } else {
                                print('실내 실외 차이가 10보다 작음');
                                inFpmDangerDifference = false;
                              }
                            }
                          } else {
                            //값을 알 수 없을 때
                            inFpmDangerDifference = false;
                            inFpmDangerValue = false;
                          }

                          if (inPmDangerValue || inFpmDangerValue) {
                            airDanger = true;
                          } else {
                            airDanger = false;
                          }

                          print("내외 미먼 차이$inPmDangerDifference");
                          print("내외 초미먼 차이$inFpmDangerDifference");
                          print("내부 미먼 경고$inPmDangerValue");
                          print("내부 초미먼 경고$inFpmDangerValue");
                          print("실외 미세먼지 좋음$pmGood");
                          print("실외 초미세먼지 좋음$fpmGood");

                          //경고 문구 가공
                          if (inPmDangerValue && inFpmDangerValue) {
                            //두 수치 모두 나쁨일 때
                            infoMessage =
                                "실내 미세먼지,초미세먼지 수치가 높습니다.\n공기 청정을 추천합니다.";
                            if (pmGood && fpmGood) {
                              infoMessage =
                                  "실내 미세먼지,초미세먼지 수치가 높습니다.\n공기 청정을 추천드립니다.\n창문을 통한 환기를 추천드립니다.";
                            }
                          } else if (inPmDangerValue) {
                            infoMessage = "실내 미세먼지 수치가 높습니다.\n공기 청정을 추천합니다.";
                            if (pmGood && fpmGood) {
                              infoMessage =
                                  "실내 미세먼지 수치가 높습니다.\n공기 청정을 추천합니다.\n창문을 통한 환기를 추천드립니다.";
                            }
                          } else if (inFpmDangerValue) {
                            infoMessage = "실내 초미세먼지 수치가 높습니다.\n공기 청정을 추천합니다.";
                            if (pmGood && pmGood) {
                              infoMessage =
                                  "실내 초미세먼지 수치가 높습니다.\n공기 청정을 추천합니다.\n창문을 통한 환기를 추천드립니다.";
                            }
                          }

                          if (airDanger) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    '안내',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  color: Colors.blueAccent,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.white70,
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    infoMessage,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Container(
                            height: 1,
                          );
                        } else {
                          return Container(
                            height: 1,
                          );
                        }
                      },
                    );
                  },
                ),
                Column(
                  children: [
                    Text(
                      '실내 미세먼지 현황',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
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
                                          category: "미세먼지",
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          marginEdgeInsets: EdgeInsets.only(
                                              top: 5, left: 5, right: 5),
                                          paddingEdgeInsets:
                                              EdgeInsets.only(top: 10),
                                        );
                                      }
                                    } else {
                                      return _NoDataCircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Container(
                                child: Text(
                                  '미세먼지',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 1, top: 1),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    border: Border(
                                        top: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                              )
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
                                          category: "초미세먼지",
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          marginEdgeInsets: EdgeInsets.only(
                                              top: 5, left: 5, right: 5),
                                          paddingEdgeInsets:
                                              EdgeInsets.only(top: 10),
                                        );
                                      }
                                    } else {
                                      return _NoDataCircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Container(
                                child: Text(
                                  '초미세먼지',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 1, top: 1),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    border: Border(
                                        top: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '실외 미세먼지 현황',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
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
                                  child: BlocBuilder<AirPollutionBloc,
                                      AirPollutionState>(
                                    builder: (context, airPollutionState) {
                                      if (airPollutionState
                                          is AirPollutionLoading) {
                                        return _NoDataCircularProgressIndicator();
                                      } else if (airPollutionState
                                          is AirPollutionLoadedAirData) {
                                        return DustStatusCircle(
                                          DustStatus:
                                              airPollutionState.pm!.toInt(),
                                          category: "미세먼지",
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          marginEdgeInsets: EdgeInsets.only(
                                              top: 5, left: 5, right: 5),
                                          paddingEdgeInsets:
                                              EdgeInsets.only(top: 10),
                                        );
                                      } else {
                                        print('무엇이 문제');
                                        return _NoDataCircularProgressIndicator();
                                      }
                                    },
                                  )),
                              Container(
                                child: Text(
                                  '미세먼지',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 1, top: 1),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    border: Border(
                                        top: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: BlocBuilder<AirPollutionBloc,
                                      AirPollutionState>(
                                    builder: (context, airPollutionState) {
                                      if (airPollutionState
                                          is AirPollutionLoading) {
                                        return _NoDataCircularProgressIndicator();
                                      } else if (airPollutionState
                                          is AirPollutionLoadedAirData) {
                                        print("로드느뇜");
                                        return DustStatusCircle(
                                          DustStatus:
                                              airPollutionState.fpm!.toInt(),
                                          category: "초미세먼지",
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          marginEdgeInsets: EdgeInsets.only(
                                              top: 5, left: 5, right: 5),
                                          paddingEdgeInsets:
                                              EdgeInsets.only(top: 10),
                                        );
                                      } else {
                                        print('무엇이 문제');
                                        return _NoDataCircularProgressIndicator();
                                      }
                                    },
                                  )),
                              Container(
                                child: Text(
                                  '초미세먼지',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 1, top: 1),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    border: Border(
                                        top: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                BlocBuilder<BerryChartDataBloc, BerryChartDataState>(
                    builder: (context, state) {
                  if (state is BerryChartDataInitial) {
                    return Center(child: Text("날짜를 선택하세요."));
                  } else if (state is BerryChartDataLoading) {
                    return Center(
                        child: CircularProgressIndicator()); // 로딩 중일 때 표시할 UI
                  } else if (state is BerryChartDataLoaded) {
                    return Container(
                      height: 400,
                      child: DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              TabBar(tabs: [
                                Tab(
                                  text: 'PM 10',
                                ),
                                Tab(
                                  text: 'PM 2.5',
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
                                _buildScrollableChart(context,state.pmData, '미세먼지',
                                    state.minPm, state.maxPm,state.currDate),
                                _buildScrollableChart(context,state.fpmData, '초미세먼지',
                                    state.minFpm, state.maxFpm,state.currDate),
                                _buildScrollableChart(context,state.tempData, '온도',
                                    state.minTemp, state.maxTemp,state.currDate),
                                _buildScrollableChart(context,state.humData, '습도',
                                    state.minHum, state.maxHum,state.currDate),
                              ]))
                            ],
                          )),
                    );
                  }
                  return Container();
                }),
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

Widget _buildScrollableChart(BuildContext context,List<Map<String, dynamic>> data, String category,
    double minY, double maxY,DateTime nowDate) {
  String formattedDate = DateFormat('yyyy-MM-dd a').format(nowDate);
  late DateTime dateMorning;
  late DateTime dateAfternoon;
  return Column(
    children: [
      Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  dateMorning = DateTime(nowDate.year,nowDate.month,nowDate.day,0,0);
                  context.read<BerryChartDataBloc>().add(BerryChartDataByDate(dateMorning));
                },
                child: Text(
                  '오전',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Palette.buttonColor),
                ),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: () {
                      dateAfternoon = DateTime(nowDate.year,nowDate.month,nowDate.day,12,0);
                      context.read<BerryChartDataBloc>().add(BerryChartDataByDate(dateAfternoon));
                    },
                    child: Text(
                      '오후',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Palette.buttonColor),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))))
          ],
        ),
      ),

      SizedBox(height: 10),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 2500, // 적절한 너비 설정
            margin: EdgeInsets.only(top: 10),
            child: DustBarChart(
              dustData: data,
              title: category,
              category: category,
              minY: minY,
              maxY: maxY,
            ),
          ),
        ),
      ),
      Container(alignment: Alignment.center,child: Text('검색 시간: $formattedDate',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),),
    ],
  );
}

Widget _NoDataCircularProgressIndicator() {
  return Container(
      margin: EdgeInsets.only(top: 5, left: 5, right: 5),
      padding: EdgeInsets.only(top: 10),
      //width: MediaQuery.of(context).size.width / 2 - 20,
      //1height: MediaQuery.of(context).size.width / 2 - 20,
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Stack(
        children: [Center(child: CircularProgressIndicator())],
      ));
}
