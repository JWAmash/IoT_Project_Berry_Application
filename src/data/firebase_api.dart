// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:iot_project_berry/main.dart';
// import 'package:iot_project_berry/src/screens/screenBerry.dart';
//
// class FirebaseApi {
//   // 파이어베이스 메시지 인스턴스 생성
//   final _firebaseMessaging = FirebaseMessaging.instance;
//
//   // notification 초기화 함수
//   Future<void> iniNotifications() async {
//     // 사용자에게 권한 요청
//     await _firebaseMessaging.requestPermission();
//     // Firebase Cloud 메시징 토큰 생성
//     final fcMToken = await _firebaseMessaging.getToken();
//     //서버에 내 토큰 저장 해야함 일단 임시로 출력
//
//     print('토큰: $fcMToken');
//     // 시작할 때 initPushNotifications 호출
//     initPushNotifications();
//   }
//
//   //수신 메시지 handler
//   void handleMessage(RemoteMessage? message) {
//     // if the message is null, do nothing
//     if (message == null) return;
//     // 메시지를 받은 상태에서 notification클릭시 화면 이동
//     navigatorKey.currentState?.push(
//         MaterialPageRoute(builder: (_) => ScreenBerry()));
//   }
//
//   // background 셋팅
//   Future initPushNotifications() async {
//     // 앱이 종료되었다가 열리면 실행하는 handler
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     // 앱을 열 때 이벤트 리스너를 첨부
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {})
//   }
//   Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
//     print("백그라운드 메시");
//   }
// }