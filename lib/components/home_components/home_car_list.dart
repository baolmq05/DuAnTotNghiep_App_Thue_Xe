import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_card.dart';
import 'package:flutter/material.dart';

class HomeCarList extends StatelessWidget {
  const HomeCarList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Xe nổi bật gần bạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Car List
        SizedBox(
          height: 400,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return const HomeCarCard(width: 320);
            },
          ),
        ),
      ],
    );
  }
}
