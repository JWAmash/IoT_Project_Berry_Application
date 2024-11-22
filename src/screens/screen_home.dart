import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/blocs/airpollution_bloc.dart';
import 'package:iot_project_berry/src/blocs/berrychart_bloc.dart';
import 'package:iot_project_berry/src/blocs/location_state.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/blocs/weather_bloc.dart';
import 'package:iot_project_berry/src/config/palette.dart';
import 'package:iot_project_berry/src/screens/ScreenB.dart';
import 'package:iot_project_berry/src/screens/screenBerry.dart';
import 'package:iot_project_berry/src/screens/screenBlind.dart';
import 'package:iot_project_berry/src/screens/screenDoorLock.dart';
import 'package:iot_project_berry/src/screens/screenLantern.dart';
import 'package:iot_project_berry/src/widgets/dust_statuscircle.dart';
import 'package:iot_project_berry/src/widgets/weatherlinechart.dart';
import 'package:timer_builder/timer_builder.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final String temptopic = "berry/home/temperature";
  final String pm = "pm2.5";
  final String fpm = "pm10";
  final String temp = "temp";
  final String humidity = "hum";

  //final String address='';

  String getSystemTime() {
    var now = DateTime.now();
    return DateFormat("h:mm a").format(now);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () =>
                  context.read<LocationBloc>().add(GetMyCurrentLocation()),
              icon: Icon(Icons.location_on),
          tooltip: '현재 위치를 다시 검색합니다.',),
          IconButton(
              onPressed: () => context.read<WeatherBloc>().add(FetchWeather(
                    latx: context.read<LocationBloc>().latx!,
                    laty: context.read<LocationBloc>().laty!,
                  )),
              icon: Icon(Icons.refresh),
          tooltip: '날씨 새로고침 기능입니다.\n날씨 정보를 새로 받아옵니다.',)
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       UserAccountsDrawerHeader(
      //           currentAccountPicture: CircleAvatar(
      //               backgroundColor: Colors.teal[200],
      //               backgroundImage: AssetImage('assets/Icon1.jpg')),
      //           accountName: Text('좌승혁'),
      //           accountEmail: Text('test@naver.com')),
      //       ListTile(
      //         leading: Icon(
      //           Icons.home,
      //           color: Colors.grey[850],
      //         ),
      //         title: Text('home'),
      //         onTap: () {
      //           Navigator.push(
      //               context, MaterialPageRoute(builder: (_) => ScreenBerry()));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(
      //           Icons.settings,
      //           color: Colors.grey[850],
      //         ),
      //         title: Text('setting'),
      //         onTap: () {
      //           Navigator.push(
      //               context, MaterialPageRoute(builder: (_) => ScreenB()));
      //         },
      //       )
      //     ],
      //   ),
      // ),
      body: SafeArea(
          child: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.blue[100],
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TimerBuilder.periodic(
                        Duration(days: 1),
                        builder: (context) {
                          return Text(
                              DateFormat('yyy. MM.d(EEEE),')
                                  .format(DateTime.now()),
                              style: GoogleFonts.lato(
                                  fontSize: 20.0, color: Colors.white));
                        },
                      ),
                      TimerBuilder.periodic(Duration(minutes: 1),
                          builder: (context) {
                        print('${getSystemTime()}');
                        return Text(
                          '${getSystemTime()}',
                          style: GoogleFonts.lato(
                              fontSize: 45.0, color: Colors.white),
                        );
                      }),
                    ],
                  ),
                  //여기부터
                  Column(
                    children: [
                      BlocBuilder<LocationBloc, LocationState>(
                        builder: (context, locationState) {
                          if (locationState is LocationLoading) {
                            return CircularProgressIndicator();
                          } else if (locationState is LocationLoaded ||
                              locationState is LocationUnchanged) {
                            final loadedState = locationState as LocationLoaded;
                            return Container(
                              alignment: Alignment.center,
                              //margin: EdgeInsets.only(left: 40),
                              child: Text(
                                '주소: ${loadedState.address}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          } else if (locationState is LocationError) {
                            return Text(locationState.message);
                          }
                          return Container();
                        },
                      ),
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, weatherState) {
                          if (weatherState is WeatherLoading) {
                            return CircularProgressIndicator();
                          } else if (weatherState is WeatherLoaded) {
                            return Column(
                              children: [
                                // Text(
                                //     '날씨 정보 ${weatherState.weatherUSFData['response']['body']['items']['item'][1]}'),
                                LineChartSample2(
                                    organizedUSFData:
                                        weatherState.processedWeatherUSFData,
                                    organizedVFData:
                                        weatherState.processedWeatherVFData)
                                // ElevatedButton(
                                //   onPressed: () => context.read<WeatherBloc>().add(FetchWeather(
                                //     latx: context.read<LocationBloc>().state.latx!,
                                //     laty: context.read<LocationBloc>().state.laty!,
                                //   )),
                                //   child: Text('날씨 새로고침'),
                                //),
                              ],
                            );
                          } else if (weatherState is WeatherError) {
                            return Text(weatherState.message);
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),

                  //여기까지
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: Column(
                        children: [
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 5),
                              margin:
                                  EdgeInsets.only(top: 5, right: 5, left: 5),
                              width: double.infinity,
                              //color: Colors.green,
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: Text(
                                "실내 PM2.5",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          AspectRatio(
                            aspectRatio: 1,
                            child: BlocBuilder<MqttBloc, MqttState>(
                              builder: (context, mqttState) {
                                if (mqttState is MqttDisconnected) {
                                  return _buildCircleprogressdata();
                                } else if (mqttState is MqttConnected) {
                                  if ((mqttState.messages[temptopic] != null &&
                                          mqttState.messages[temptopic]![pm] ==
                                              null) ||
                                      (mqttState.messages[temptopic] == null)) {
                                    return _buildCircleprogressdata();
                                  } else {
                                    return DustStatusCircle(
                                      DustStatus:
                                          mqttState.messages[temptopic]![pm],
                                      category: "초미세먼지",
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      marginEdgeInsets: const EdgeInsets.only(
                                          bottom: 5, right: 5, left: 5),
                                      paddingEdgeInsets:
                                          const EdgeInsets.only(top: 5),
                                    );
                                  }
                                } else {
                                  return _buildCircleprogressdata();
                                }
                              },
                            ),
                          )
                        ],
                      )),
                      Flexible(
                          child: Column(
                        children: [
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 5),
                              margin:
                                  EdgeInsets.only(top: 5, right: 5, left: 5),
                              width: double.infinity,
                              //color: Colors.green,
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: Text(
                                "실내 PM10",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          AspectRatio(
                            aspectRatio: 1,
                            child: BlocBuilder<MqttBloc, MqttState>(
                              builder: (context, mqttState) {
                                if (mqttState is MqttDisconnected) {
                                  return _buildCircleprogressdata();
                                } else if (mqttState is MqttConnected) {
                                  if ((mqttState.messages[temptopic] != null &&
                                          mqttState.messages[temptopic]![fpm] ==
                                              null) ||
                                      (mqttState.messages[temptopic] == null)) {
                                    return _buildCircleprogressdata();
                                  } else {
                                    return DustStatusCircle(
                                        DustStatus:
                                            mqttState.messages[temptopic]![fpm],
                                        category: "미세먼지",
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        marginEdgeInsets: EdgeInsets.only(
                                            bottom: 5, right: 5, left: 5),
                                        paddingEdgeInsets:
                                            EdgeInsets.only(top: 5));
                                  }
                                } else {
                                  return _buildCircleprogressdata();
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                      Flexible(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 5),
                              margin:
                                  EdgeInsets.only(top: 5, right: 5, left: 5),
                              width: double.infinity,
                              //color: Colors.green,
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: Text(
                                "실내 온도",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          AspectRatio(
                            aspectRatio: 1,
                            child: BlocBuilder<MqttBloc, MqttState>(
                              builder: (context, mqttState) {
                                if (mqttState is MqttDisconnected) {
                                  return _buildCircleprogressdata();
                                } else if (mqttState is MqttConnected) {
                                  if ((mqttState.messages[temptopic] != null &&
                                          mqttState
                                                  .messages[temptopic]![temp] ==
                                              null) ||
                                      (mqttState.messages[temptopic] == null)) {
                                    return _buildCircleprogressdata();
                                  } else {
                                    return DustStatusCircle(
                                      DustStatus:
                                          mqttState.messages[temptopic]![temp].toInt(),
                                      category: "온도",
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      marginEdgeInsets: EdgeInsets.only(
                                          bottom: 5, right: 5, left: 5),
                                      paddingEdgeInsets:
                                          EdgeInsets.only(top: 5),
                                    );
                                  }
                                } else {
                                  return _buildCircleprogressdata();
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                      Flexible(
                          child: Column(
                        children: [
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 5),
                              margin:
                                  EdgeInsets.only(top: 5, right: 5, left: 5),
                              width: double.infinity,
                              //color: Colors.green,
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: Text(
                                "실내 습도",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          AspectRatio(
                            aspectRatio: 1,
                            child: BlocBuilder<MqttBloc, MqttState>(
                              builder: (context, mqttState) {
                                if (mqttState is MqttDisconnected) {
                                  return CircularProgressIndicator();
                                } else if (mqttState is MqttConnected) {
                                  if ((mqttState.messages[temptopic] != null &&
                                          mqttState.messages[temptopic]![
                                                  humidity] ==
                                              null) ||
                                      (mqttState.messages[temptopic] == null)) {
                                    return _buildCircleprogressdata();
                                  } else {
                                    return DustStatusCircle(
                                        DustStatus: mqttState
                                            .messages[temptopic]![humidity].toInt(),
                                        category: "습도",
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        marginEdgeInsets: EdgeInsets.only(
                                            bottom: 5, right: 5, left: 5),
                                        paddingEdgeInsets:
                                            EdgeInsets.only(top: 5));
                                  }
                                } else {
                                  return _buildCircleprogressdata();
                                }
                              },
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            width: 150,
                            child: Text(
                              '기기별 제어',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                            ),
                          ),
                          SizedBox(
                            width: 150,
                          )
                        ],
                      ),
                      Divider(
                        height: 15.0,
                        thickness: 1.0,
                        color: Colors.black26,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 130,
                            height: 70,
                            margin: EdgeInsets.all(10),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MultiBlocProvider(providers: [
                                                BlocProvider<
                                                        BerryChartDataBloc>(
                                                    create: (context) =>
                                                        BerryChartDataBloc()),
                                                BlocProvider<AirPollutionBloc>(
                                                  create: (context) =>
                                                      AirPollutionBloc(),
                                                )
                                              ], child: ScreenBerry())));
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.speaker,
                                      size: 35,
                                      color: Color(0xFF5985E1),
                                    ),
                                    Text(
                                      "베리",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: Palette.buttonColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ))),
                          ),
                          // _buildHomeButton(
                          //     context,
                          //     "베리",
                          //     ScreenBerry(),
                          //     Icon(
                          //       Icons.speaker,
                          //       color: Color(0xFF5985E1),
                          //     )),
                          _buildHomeButton(
                              context,
                              "도어락",
                              screenDoorLock(),
                              Icon(Icons.meeting_room,
                                  size: 35, color: Color(0xFF5985E1))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHomeButton(
                              context,
                              "블라인드",
                              ScreenBlind(),
                              Icon(
                                Icons.blinds,
                                color: Color(0xFF5985E1),
                                size: 35,
                              )),
                          _buildHomeButton(
                              context,
                              "조명",
                              screenLantern(),
                              Icon(Icons.light,
                                  size: 35, color: Color(0xFF5985E1))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       heroTag: 'restartlocation',
      //       onPressed: () =>
      //           context.read<LocationBloc>().add(GetMyCurrentLocation()),
      //       child: Icon(Icons.location_on),
      //     ),
      //     SizedBox(width: 10),
      //     FloatingActionButton(
      //       heroTag: 'restartweather',
      //       onPressed: () => context.read<WeatherBloc>().add(FetchWeather(
      //             latx: context.read<LocationBloc>().latx!,
      //             laty: context.read<LocationBloc>().laty!,
      //           )),
      //       child: Icon(Icons.refresh),
      //     ),
      //   ],
      // ),
    );
  }
}

Widget _buildHomeButton(
    BuildContext context, String title, Widget page, Icon icon) {
  return Container(
    width: 130,
    height: 70,
    margin: EdgeInsets.all(10),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Text(
            title,
            style: TextStyle(
                fontSize: 18.0,
                color: Palette.buttonColor,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )),
    ),
  );
}

Widget _buildCircleprogressdata() {
  return Container(
      margin: EdgeInsets.only(bottom: 5, right: 5, left: 5),
      padding: EdgeInsets.only(top: 5),
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
