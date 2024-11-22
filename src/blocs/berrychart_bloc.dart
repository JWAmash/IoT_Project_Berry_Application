// fetch_data_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BerryChartDataState {}

class BerryChartDataInitial extends BerryChartDataState {}

class BerryChartDataLoading extends BerryChartDataState {}

class BerryChartDataLoaded extends BerryChartDataState {
  final List<Map<String, dynamic>> pmData;
  final List<Map<String, dynamic>> fpmData;
  final List<Map<String, dynamic>> tempData;
  final List<Map<String, dynamic>> humData;
  final double minPm;
  final double minFpm;
  final double minHum;
  final double minTemp;
  final double maxPm;
  final double maxFpm;
  final double maxHum;
  final double maxTemp;
  final DateTime currDate;

  BerryChartDataLoaded({
    required this.pmData,
    required this.fpmData,
    required this.tempData,
    required this.humData,
    required this.minPm,
    required this.minFpm,
    required this.minHum,
    required this.minTemp,
    required this.maxPm,
    required this.maxFpm,
    required this.maxHum,
    required this.maxTemp,
    required this.currDate
  });
}

class BerryChartDataError extends BerryChartDataState {
  final String message;

  BerryChartDataError(this.message);
}

// fetch_data_event.dart
abstract class BerryChartDataEvent {}

class BerryChartDataByDate extends BerryChartDataEvent {
  final DateTime date;

  BerryChartDataByDate(this.date);
}

class BerryChartDataBloc
    extends Bloc<BerryChartDataEvent, BerryChartDataState> {
  double minpm = 0;
  double minfpm = 0;
  double minhum = 0;
  double mintemp = 0;
  double maxpm = 200;
  double maxfpm = 100;
  double maxhum = 0;
  double maxtemp = 50;

  // 초기 상태는 BerryChartDataInitial로 설정
  BerryChartDataBloc() : super(BerryChartDataInitial()) {
    // 이벤트 핸들러 등록
    on<BerryChartDataByDate>(_onGetData);
  }

  // 이벤트 핸들러: 데이터를 가져오는 로직 처리
  Future<void> _onGetData(
      BerryChartDataByDate event, Emitter<BerryChartDataState> emit) async {
    emit(BerryChartDataLoading()); // 로딩 상태로 전환
    print("현재시간: ${event.date}");
    try {
      // 데이터를 저장할 리스트들
      List<Map<String, dynamic>> pmData = [];
      List<Map<String, dynamic>> fpmData = [];
      List<Map<String, dynamic>> tempData = [];
      List<Map<String, dynamic>> humData = [];

      // Firestore에서 데이터를 가져오는 함수 호출
      await fetchFirestoreData(event.date, pmData, fpmData, tempData, humData);
      print("이건온건데");
      // 데이터 가공 함수 호출
      String dateString =
          "${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}";
      bool isAM = event.date.hour < 12;
      print("일단 시간: $isAM");
      print("미세먼지 리스트: $pmData");
      print("초미세먼지 리스트: $fpmData");
      print("온도 리스트: $tempData");
      print("습도 리스트: $humData");
      pmData = processDataForChart(pmData, dateString, isAM);
      fpmData = processDataForChart(fpmData, dateString, isAM);
      tempData = processDataForChart(tempData, dateString, isAM);
      humData = processDataForChart(humData, dateString, isAM);

      // 데이터를 성공적으로 가져오면 Loaded 상태로 전환
      emit(BerryChartDataLoaded(
        pmData: pmData,
        fpmData: fpmData,
        tempData: tempData,
        humData: humData,
        minPm: minpm,
        minFpm: minfpm,
        minTemp: mintemp,
        minHum: minhum,
        maxPm: maxpm,
        maxFpm: maxfpm,
        maxTemp: maxtemp,
        maxHum: maxhum,
        currDate: event.date
      ));
      print('이시간인데: ${event.date}');
      print("이거 만들어짐: $pmData");
      print(fpmData);
      print(tempData);
      print(humData);
      print("최소 $mintemp");
    } catch (e) {
      // 에러가 발생하면 Error 상태로 전환
      emit(BerryChartDataError("Error fetching data: $e"));
    }
  }

  // Firestore에서 데이터를 가져오는 함수
  Future<void> fetchFirestoreData(
    DateTime date,
    List<Map<String, dynamic>> pmList,
    List<Map<String, dynamic>> fpmList,
    List<Map<String, dynamic>> tempList,
    List<Map<String, dynamic>> humList,
  ) async {
    String datePrefix =
        "sensor_data_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_";

    bool isAM = date.hour < 12;
    String startTime = isAM ? "00" : "12";
    String endTime = isAM ? "12" : "24";
    print("몇번이나 불러오냐!!!!!!!!!!!!!");
    print("검색어: ${datePrefix}${startTime}");
    print("검색어: ${datePrefix}${endTime}");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc('berry')
        .collection('particulatematter')
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: "${datePrefix}${startTime}")
        .where(FieldPath.documentId,
            isLessThanOrEqualTo: "${datePrefix}${endTime}")
        .get();

    print("몇번이나 불러오냐2!!!!!!!!!!!!!");
    // if (querySnapshot.docs.isEmpty) {
    //   throw Exception("No data found for the specified date.");
    // }
    print("몇번이나 불러오냐6!!!!!!!!!!!!!");
    for (var docSnapshot in querySnapshot.docs) {
      try {
        print("몇번이나 불러오냐5!!!!!!!!!!!!!");
        final data = docSnapshot.data() as Map<String, dynamic>;
        DateTime dateTime = (data['timestamp'] as Timestamp).toDate();
        String formattedTime =
            "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
        print("이 데이터가 들어왔따는건데: $data");
        if (data.containsKey('PM 2.5 평균')) {
          double fpm25Avg = data['PM 2.5 평균'].toDouble();
          //Y기준 데이터 찾기
          if (minfpm > fpm25Avg) minfpm = fpm25Avg;
          if (maxfpm < fpm25Avg) maxfpm = fpm25Avg;

          fpmList.add({
            'time': formattedTime,
            'Value': fpm25Avg,
          });
        }
        print("몇번이나 불러오냐3!!!!!!!!!!!!!");
        if (data.containsKey('PM 10.0 평균')) {
          double pmAvg = data['PM 10.0 평균'].toDouble();
          //Y기준 데이터 찾기
          if (minpm > pmAvg) minpm = pmAvg;
          if (maxpm < pmAvg) maxpm = pmAvg;
          pmList.add({
            'time': formattedTime,
            'Value': pmAvg,
          });
        }
        print("몇번이나 불러오냐4!!!!!!!!!!!!!");
        if (data.containsKey('온도 평균')) {
          double tempAvg = data['온도 평균'].toDouble();
          //Y기준 데이터 찾기
          if (mintemp > tempAvg) mintemp = tempAvg;
          if (maxtemp < tempAvg) maxtemp = tempAvg;
          tempList.add({
            'time': formattedTime,
            'Value': tempAvg,
          });
        }
        print("최대온도$maxtemp 최소온도 $mintemp");
        print("몇번이나 불러오냐7!!!!!!!!!!!!!");
        if (data.containsKey('습도 평균')) {
          double humAvg = data['습도 평균'].toDouble();
          //Y기준 데이터 찾기
          if (minhum > humAvg) minhum = humAvg;
          if (maxhum < humAvg) maxhum = humAvg;
          humList.add({
            'time': formattedTime,
            'Value': humAvg,
          });
        }
        print("일단 끝났음");
      } catch (e) {
        print("데이터 처리중 오류가 발생 :$e");
        continue;
      }
    }
  }

  List<Map<String, dynamic>> processDataForChart(
      List<Map<String, dynamic>> rawData, String date, bool isAM) {
    List<Map<String, dynamic>> processedData = [];
    DateTime startTime =
        DateTime.parse("$date ${isAM ? '00:00:00' : '12:00:00'}");
    DateTime endTime = startTime.add(Duration(hours: 12));

    int rawDataIndex = 0;
    print("들어오긴한건가 가공프로세스");
    while (startTime.isBefore(endTime)) {
      String timeString =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

      if (rawDataIndex < rawData.length &&
          rawData[rawDataIndex]['time'] == timeString) {
        processedData.add(rawData[rawDataIndex]);
        rawDataIndex++;
      } else {
        processedData.add({
          'time': timeString,
          'Value': 0.0,
        });
      }
      startTime = startTime.add(Duration(minutes: 15));
    }

    return processedData;
  }
}
