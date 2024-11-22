import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/blocs/location_state.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/blocs/weather_bloc.dart';
import 'package:iot_project_berry/src/screens/screen_home.dart';
import 'package:iot_project_berry/src/screens/screen_tabview.dart';

class ScreenLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 위치 가져오기 이벤트를 초기화 시점에 등록
    context.read<LocationBloc>().add(GetMyCurrentLocation());
    context.read<MqttBloc>().add(ConnectMqtt(server: 'broker.hivemq.com', port: 1883, clientId: 'flutter_client'));
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, locationState) {
              if (locationState is LocationLoaded) {
                context.read<WeatherBloc>().add(FetchWeather(
                  latx: locationState.latx!,
                  laty: locationState.laty!,
                ));
              }
            },
          ),
          BlocListener<WeatherBloc, WeatherState>(
            listener: (context, weatherState) {
              print('여긴 도착했나');
              if (weatherState is WeatherLoaded) {
                print('날씨 정보 로드 완료');
                _checkAllDataLoaded(context);
              }
            },
          ),
          BlocListener<MqttBloc,MqttState>(listener: (context, mqttState) {
            if (mqttState is MqttConnected){
              print('MQTT 연결 완료');
              _checkAllDataLoaded(context);
            }
          },)
        ],
        child: Center(child: CircularProgressIndicator()), // 로딩 표시
      ),
    );
  }
}
void _checkAllDataLoaded(BuildContext context) {
  final locationState = context.read<LocationBloc>().state;
  final weatherState = context.read<WeatherBloc>().state;
  final mqttState = context.read<MqttBloc>().state;

  if (locationState is LocationLoaded &&
      weatherState is WeatherLoaded &&
      mqttState is MqttConnected) {
    print('모든 데이터 로드 완료, 구독 시작');
    //final mqttBloc = context.read<MqttBloc>();


    context.read<MqttBloc>()
      ..add(SubscribeTopic(topic: 'berry/home/temperature'))
      ..add(SubscribeTopic(topic: 'berry/home/humidity'))
      ..add(SubscribeTopic(topic: 'berry/home/test'))
      ..add(SubscribeTopic(topic: 'berry/blind'));

    final mqttBloc = context.read<MqttBloc>();
    mqttBloc.logSubscribeTopics();
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainTabView()));
  }
}