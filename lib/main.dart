import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MaterialApp(home: MicPage(),));
}

class MicPage extends StatefulWidget{
  const MicPage({super.key});

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {

  final Record record = Record();
  Timer? timer;

  double volume = 0.0;
  double minVolume = -45.0;

  startTime() async{
    timer ??= Timer.periodic(Duration(microseconds: 1000), (timer) => updateVolume());
  }

  updateVolume() async{
    Amplitude ampl = await record.getAmplitude();
    if (ampl.current > minVolume){
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
      });
      print("volume: $volume");
    }
  }

  int volume0to(int maxVolumeToDisplay){
    return (volume * maxVolumeToDisplay).round().abs();
  }

  Future<bool> startRecording() async {
    if (await record.hasPermission()){
      const encoder = AudioEncoder.aacLc;

      final devs = await record.listInputDevices();
      debugPrint(devs.toString());

      if (!await record.isRecording()){
        await record.start();
      }
      startTime();
      return true;
    }else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(future: startRecording(), builder: (context, snapshot){
      double opacity = 0.0;
      if(snapshot.hasData){
        int vol = volume0to(100);
        opacity = (vol / 100).clamp(0.0, 1.0);
      }
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          // child: Text(snapshot.hasData? volume0to(100).toString() : 'No data'),
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              'assets/images/wangda.png',
              width: 200,
              height: 500,
            ),
          ),
        ));
    });
  }
}

