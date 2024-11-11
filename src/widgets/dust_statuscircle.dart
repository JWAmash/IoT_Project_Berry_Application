import 'package:flutter/material.dart';
import 'package:iot_project_berry/src/config/palette.dart';

class DustStatusCircle extends StatefulWidget {
  final int DustStatus;
  final bool isFineDust;
  final BorderRadius borderRadius;
  final EdgeInsets marginEdgeInsets;
  final EdgeInsets paddingEdgeInsets;
  final bool haveData;

  const DustStatusCircle(
      {super.key,
      required this.DustStatus,
      required this.isFineDust,
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
      return "ERROR";
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

  String pmStatusText(int dustValue) {
    if (dustValue > 150) {
      return "매우 나쁨";
    } else if (dustValue > 80) {
      return "나쁨";
    } else if (dustValue > 50) {
      return "보통";
    } else if (dustValue >= 0) {
      return "좋음";
    } else {
      return "ERROR";
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.DustStatus;
    final isFineDust = widget.isFineDust;
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
                      color: isFineDust
                          ? getColorByFPMValue(status)
                          : getColorByPMValue(status),
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                );
              }),
            ),
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isFineDust ? fpmStatusText(status) : pmStatusText(status),
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      status.toString(),
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
