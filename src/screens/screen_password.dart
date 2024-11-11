import 'package:flutter/material.dart';

class ScreenPassword extends StatefulWidget {
  const ScreenPassword({super.key});

  @override
  State<ScreenPassword> createState() => _ScreenPasswordState();
}

class _ScreenPasswordState extends State<ScreenPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.blue,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 400, color: Colors.brown, child: Text('페이지 어카지')),
                Container(
                    width: 400, color: Colors.brown, child: Text('페이지 어카지')),
                Container(
                    width: 400, color: Colors.brown, child: Text('페이지 어카지')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
