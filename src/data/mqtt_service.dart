import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  // 싱글톤 인스턴스
  static final MQTTService _instance = MQTTService._internal();

  // MQTT 클라이언트
  MqttServerClient? client;

  // private 생성자
  MQTTService._internal();

  // 인스턴스를 반환하는 factory constructor
  factory MQTTService() {
    return _instance;
  }

  // MQTT 연결 함수
  Future<void> connect(String server,int port, String clientId) async {
    // client = MqttServerClient('test.mosquitto.org', 'test_mqtt');
    // client!.port = 1883;
    client = MqttServerClient(server,clientId);
    client!.port=port;
    client!.keepAlivePeriod = 20;
    //client!.onConnected = onConnected;
    //client!.onDisconnected = onDisconnected;

    try {
      await client!.connect();
    } catch (e) {
      print('MQTT 연결 실패: $e');
    }
  }

  // void onConnected() {
  //   print('MQTT 연결 성공');
  // }

  //void onDisconnected() {
    //print('MQTT 연결 끊김');
  //}
  void disconnect(){
    client?.disconnect();
  }

  // 메시지 전송 함수
  // void publish(String topic, Map<String,dynamic> message) {
  void publish(String topic, String message) {
    // final jsonString = json.encode(message);
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    //builder.addString(jsonString);
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  //수신 함수
  Stream<List<MqttReceivedMessage<MqttMessage>>> subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atLeastOnce);
    return client!.updates!;
  }
}