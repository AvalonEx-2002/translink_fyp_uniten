// analog_clock_widget.dart
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter/material.dart';

class AnalogClockWidget extends StatelessWidget {
  const AnalogClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.0,
        height: 300.0,
        child: AnalogClock(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3.0,
              color: Colors.black54,
            ),
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          isLive: true,
          hourHandColor: Colors.black,
          minuteHandColor: Colors.black,
          showSecondHand: true,
          secondHandColor: Colors.red,
          numberColor: Colors.blueAccent,
          showNumbers: true,
          showAllNumbers: false,
          textScaleFactor: 1.4,
          showTicks: true,
          tickColor: Colors.grey,
          showDigitalClock: true,
          digitalClockColor: Colors.green,
          datetime: DateTime.now(),
        ),
      ),
    );
  }
}
