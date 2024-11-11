import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:iot_project_berry/src/blocs/location_state.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/blocs/weather_bloc.dart';
import 'package:iot_project_berry/src/data/push_Notification_Service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iot_project_berry/src/screens/screen_loading.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dcdg/dcdg.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String apikey = dotenv.env['weatherapikey'].toString();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting(); // 이 부분을 추가
  //await FirebaseApi().iniNotifications();
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initPushNotifications();

  try{
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print('익명 로그인 성공');
    } else {
      print('이미 로그인된 사용자: ${user.uid}');
    }
  }catch(e){
    print('로그인 오류: $e');
  }

  
  await dotenv.load(fileName: '.env');
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(),
        ),
        BlocProvider<WeatherBloc>(
          create: (context) =>
              WeatherBloc(weatherService: WeatherService(apikey: apikey)),
        ),
        BlocProvider<MqttBloc>(
          create: (context) => MqttBloc(),
        )
      ],
      child: MaterialApp(
        title: 'test blov',
        navigatorKey: navigatorKey,
        theme: ThemeData(primaryColor: Colors.blue),
        home: ScreenLoading(),
      ),
    );
  }
}
