import 'package:flutter/material.dart';
import 'package:translink/components/analog_clock.dart';

class HomeDisplayPage extends StatefulWidget {
  const HomeDisplayPage({super.key});

  @override
  State<HomeDisplayPage> createState() => _HomeDisplayPageState();
}

class _HomeDisplayPageState extends State<HomeDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnalogClockWidget(),
        ],
      ),
    );
  }
}
