import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iot_project_berry/main.dart';
import 'package:http/http.dart' as http;
import 'package:iot_project_berry/src/data/local_notification_service.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final String SERVER_URL =
      '임시URL'; // 서버 URL 변경해야함
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  Future<void> initPushNotifications() async {
    await _localNotificationService.initialize();

    // FCM 권한 요청 (iOS에서 필요)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // FCM 토큰 가져오기
    String? token = await _fcm.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // TODO: 이 토큰을 서버에 전송하여 저장
      //await saveTokenToServer(token);
    }

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 앱이 종료되었다가 열리면 실행하는 핸들러
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage, appState: 'terminated');
    }

    // 백그라운드에서 알림을 탭했을 때 실행되는 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message, appState: 'background');
    });

    // 백그라운드 메시지 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> saveTokenToServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse(SERVER_URL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fcm_token': token}),
      );
      if (response.statusCode == 200) {
        print('Token saved successfully to server');
      } else {
        print('Failed to save token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      print('알림 제목: ${message.notification?.title}');
      print('알림 내용: ${message.notification?.body}');
      _localNotificationService.showNotification(message);
    }
  }

  void _handleMessage(RemoteMessage message, {required String appState}) {
    print('Handling a message (App state: $appState)');
    print('Message data: ${message.data}');

    if (appState == 'terminated') {
      // 앱이 종료된 상태에서의 특별한 처리
      print('App was terminated. Performing special actions...');
      // 예: 특정 데이터 초기화 또는 특별한 화면으로 이동
    }

    // 공통 처리 로직 (예: 특정 화면으로 이동)
    //navigatorKey.currentState?.pushNamed('/screen_berry', arguments: message);
  }
}

// 최상위 레벨 함수로 정의
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // TODO: 백그라운드에서 필요한 작업 수행
  //navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => main()));
}
