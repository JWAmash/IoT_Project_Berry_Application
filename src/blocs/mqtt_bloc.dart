import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/data/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

//State
abstract class MqttState {}

class MqttInitial extends MqttState {}

//class MqttConnected extends MqttState {}
class MqttConnected extends MqttState {
  final Map<String, Map<String, dynamic>> messages;
  final bool isConnected;

  MqttConnected({this.messages = const {}, this.isConnected = true});

  MqttConnected copyWith({
    Map<String, Map<String, dynamic>>? messages,
    bool? isConnected,
  }) {
    return MqttConnected(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class MqttDisconnected extends MqttState {}

class MqttSubtopic extends MqttState {}


//Event
abstract class MqttEvent {}

class ConnectMqtt extends MqttEvent {
  final String server;
  final int port;
  final String clientId;
  ConnectMqtt({required this.server, required this.port, required this.clientId});
}

class SubscribeTopic extends MqttEvent {
  final String topic;

  SubscribeTopic({required this.topic});
}

class PublishMessage extends MqttEvent {
  final String topic;
  final String message;

  PublishMessage({required this.topic, required this.message});
}

class MqttMessageReceived extends MqttEvent {
  final String topic;
  final String message;

  MqttMessageReceived({required this.topic, required this.message});
}

//Bloc
class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MQTTService mqttService = MQTTService();
  final Set<String> _subscribedTopics = {};
  Map<String, Map<String,dynamic>> _messages = {};

  // Initialize MQTT client and listen for messages
  MqttBloc() : super(MqttInitial()) {
    on<ConnectMqtt>(_onConnect);
    on<SubscribeTopic>(_onSubscribe);
    on<PublishMessage>(_onPublish);
    on<MqttMessageReceived>(_onMessageReceived);
  }

  Future<void> _onConnect(ConnectMqtt event, Emitter<MqttState> emit) async {
    try {
      await mqttService.connect(event.server,event.port,event.clientId);
      emit(MqttConnected());
    } catch (e) {
      print('MQtt 연결 실패: $e');
      emit(MqttDisconnected());
    }
  }

  Future<void> _onSubscribe(SubscribeTopic event,Emitter<MqttState> emit) async{
    if (mqttService.client?.connectionStatus?.state == MqttConnectionState.connected) {
      try {
        if (!_subscribedTopics.contains(event.topic)) {
          mqttService.subscribe(event.topic);
          _subscribedTopics.add(event.topic);
          if (_subscribedTopics.length == 1) {
            // 첫 번째 구독일 때만 리스너 추가
            mqttService.client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
              for (var message in messages) {
                final recMess = message.payload as MqttPublishMessage;
                final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                add(MqttMessageReceived(topic: message.topic, message: payload));
              }
            });
          }
        }
      } catch (e) {
        print('구독 실패: $e');
      }
    }else{
      print('MQTT 연결아직 안됨 구독연기');
    }
  }

  void _onPublish(PublishMessage event, Emitter<MqttState> emit) {
    mqttService.publish(event.topic, event.message);
  }

  void _onMessageReceived(MqttMessageReceived event, Emitter<MqttState> emit) {
    if (state is MqttConnected){
      try {
        Map<String, dynamic> jsonData = json.decode(event.message);
        print('디코드: $jsonData, 토픽체크 : ${event.topic}');

        final currentState = state as MqttConnected;
        final updatedMessages =
            Map<String, Map<String, dynamic>>.from(currentState.messages);
        print("전에 있던 정보: ${updatedMessages}");
        if(updatedMessages.containsKey(event.topic)){
          updatedMessages[event.topic]!.addAll(jsonData);
        }else{
          updatedMessages[event.topic] = jsonData;
        }

        print("새로운 정보: ${updatedMessages}");
        emit(currentState.copyWith(messages: updatedMessages));
      } catch (e) {
        print('JSON 파싱 오류 : $e');
      }
    }
  }
  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }

  void logSubscribeTopics(){
    print('구독된 토픽: $_subscribedTopics');
  }

}

