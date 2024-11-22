import 'package:flutter/material.dart';
import 'package:iot_project_berry/src/config/palette.dart';

class DustStatusCircle extends StatefulWidget {
  final int DustStatus;
  final String category;
  final BorderRadius borderRadius;
  final EdgeInsets marginEdgeInsets;
  final EdgeInsets paddingEdgeInsets;
  final bool haveData;

  const DustStatusCircle(
      {super.key,
      required this.DustStatus,
      required this.category,
      this.borderRadius = const BorderRadius.all(Radius.circular(10)),
      this.marginEdgeInsets = const EdgeInsets.all(5),
      this.paddingEdgeInsets = const EdgeInsets.all(0),
      this.haveData = true});

  @override
  State<DustStatusCircle> createState() => _DustStatusCircleState();
}

class _DustStatusCircleState extends State<DustStatusCircle> {
  //초미세먼지 설정
  Color getColorByFPMValue(int dustValue) {
    if (dustValue > 100) {
      return Palette.dustColorVeryBad;
    } else if (dustValue > 50) {
      return Palette.dustColorBad;
    } else if (dustValue > 15) {
      return Palette.dustColorModerate;
    } else if (dustValue >= 0) {
      return Palette.dustColorGood;
    } else {
      return Colors.white;
    }
  }

  String fpmStatusText(int dustValue) {
    if (dustValue > 100) {
      return "매우 나쁨";
    } else if (dustValue > 50) {
      return "나쁨";
    } else if (dustValue > 15) {
      return "보통";
    } else if (dustValue >= 0) {
      return "좋음";
    } else {
      return "NoData";
    }
  }

  //미세먼지 설정
  Color getColorByPMValue(int dustValue) {
    if (dustValue > 150) {
      return Palette.dustColorVeryBad;
    } else if (dustValue > 80) {
      return Palette.dustColorBad;
    } else if (dustValue > 50) {
      return Palette.dustColorModerate;
    } else if (dustValue >= 0) {
      return Palette.dustColorGood;
    } else {
      return Colors.white;
    }
  }
  //습도 설정
  Color getColorByHumValue(int value) {
    if (value < 30) {
      return Colors.red;
    } // 매우 건조한 상태
    else if (value < 50) {
      return Colors.green;
    } // 건조한 상태
    else if (value < 70) {
      return Colors.lightBlue;
    } // 쾌적한 상태
    else {
      return Colors.blue;
    }
  }

  //온도 설정
  Color getColorByTempValue(int value) {
    if (value >= 28) {
      return Palette.tempColor1;
    }
    // 매우 차가운 상태
    else if (value >= 23) {
      return Palette.tempColor2;
    } // 찬 상태
    else if (value >= 20) {
      return Palette.tempColor3;
    } else if (value >= 17) {
      return Palette.tempColor4;
    } else if (value >= 12) {
      return Palette.tempColor5;
    } else if (value >= 9) {
      return Palette.tempColor6;
    } else if (value >= 5) {
      return Palette.tempColor7;
    } else {
      return Palette.tempColor8;
    } // 매우 뜨거운 상태
  }

  String pmStatusText(int dustValue) {
    if (dustValue > 150) {
      return "매우나쁨";
    } else if (dustValue > 80) {
      return "나쁨";
    } else if (dustValue > 50) {
      return "보통";
    } else if (dustValue >= 0) {
      return "좋음";
    } else {
      return "NoData";
    }
  }
  //습도 텍스트
  String humStatusText(int value) {
    if (value < 20) {
      return "매우건조";
    } // 매우 건조한 상태
    else if (value < 40) {
      return "건조";
    } // 건조한 상태
    else if (value < 60) {
      return "쾌적";
    } // 쾌적한 상태
    else if (value < 80) {
      return "습함";
    }
    else {
      return "매우 습함";
    }
  }

  String tempStatusText(int value) {
    if (value >= 35) {
      return "폭염";
    }
    else if (value >= 28) {
      return "매우더움";
    }
    // 매우 차가운 상태
    else if (value >= 23) {
      return "더움";
    } // 찬 상태
    else if (value >= 20) {
      return "따뜻";
    } else if (value >= 17) {
      return "쾌적";
    } else if (value >= 12) {
      return "선선";
    } else if (value >= 9) {
      return "쌀쌀";
    } else if (value >= 5) {
      return "추움";
    } else {
      return "매우추움";
    }
  }


  Color getColorFromCategory(String category,int value){
    if(category=='초미세먼지') {
      return getColorByFPMValue(value);
    }else if(category=='미세먼지'){
      return getColorByPMValue(value);
    }else if(category=='온도'){
      return getColorByTempValue(value);
    }else if(category=='습도'){
      return getColorByHumValue(value);
    }else{
      //수정 필수
      return getColorByFPMValue(value);
    }
  }

  String getStatusFromCategory(String category,int value) {
    if(category=='초미세먼지') {
      return fpmStatusText(value);
    }else if(category=='미세먼지'){
      return pmStatusText(value);
    }else if(category=='온도'){
      return tempStatusText(value);
    }else if(category=='습도'){
      return humStatusText(value);
    }else{
      //수정 필수
      return "ERROR";
    }
  }

  String ErrorCheck(String category,int value){
    if(category == "초미세먼지" && value==-1){
      return "-";
    }else if(category == "미세먼지" && value==-1){
      return "-";
    }
    return value.toString();
  }
  @override
  Widget build(BuildContext context) {
    final status = widget.DustStatus;
    final String category = widget.category;
    final haveData = widget.haveData;
    return Container(
        margin: widget.marginEdgeInsets,
        padding: widget.paddingEdgeInsets,
        //width: MediaQuery.of(context).size.width / 2 - 20,
        //1height: MediaQuery.of(context).size.width / 2 - 20,
        decoration: BoxDecoration(
            color: Colors.white70, borderRadius: widget.borderRadius),
        child: Stack(
          children: [
            if(haveData)...[
            Center(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxWidth * 0.8, //너비랑 같게
                  decoration: BoxDecoration(
                      color: getColorFromCategory(category,status),
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                );
              }),
            ),
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getStatusFromCategory(category, status),
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      ErrorCheck(category, status),
                      style: TextStyle(fontSize: 15),
                    )
                  ]),
            )]
            else
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ));
  }
}
