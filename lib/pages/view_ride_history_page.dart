import 'package:flutter/material.dart';
import 'package:translink/components/my_app_bar.dart';

class ViewRideHistory extends StatefulWidget {
  const ViewRideHistory({super.key});

  @override
  State<ViewRideHistory> createState() => _ViewRideHistoryState();
}

class _ViewRideHistoryState extends State<ViewRideHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Center(
        child: Text(
          'View Ride History Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
