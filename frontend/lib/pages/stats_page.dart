import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [
      const FlSpot(0, 30), const FlSpot(1, 45), const FlSpot(2, 50), const FlSpot(3, 55), const FlSpot(4, 60),
      const FlSpot(5, 65), const FlSpot(6, 70), const FlSpot(7, 75), const FlSpot(8, 80), const FlSpot(9, 85),
      const FlSpot(10, 90), const FlSpot(11, 95), const FlSpot(12, 100), const FlSpot(13, 95), const FlSpot(14, 90),
    ];

    return Scaffold(
      appBar: top_app_bar(centerText: 'Stats', onSettingsTap: () {}),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats boxes
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatsBox(
                    boxColor: Colors.blue[400],
                    firstIcon: Icons.add_chart_sharp,
                    secondLine: '85%',
                    thirdLine: 'Average',
                    fourthLine: 'Form Score'
                  ),
                  StatsBox(
                    boxColor: Colors.green[400],
                    firstIcon: Icons.token,
                    secondLine: '12',
                    thirdLine: 'Perfect Form',
                    fourthLine: 'Streaks'
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // Weekly Progress Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 280,
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment(-0.75, 0),
                      child: Text('Weekly Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      height: 216,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text(
                                    'Date',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(fontSize: 10, color: Colors.black);
                                      String text = '';
                                      if (value.toInt() % 2 == 0) {
                                        text = '${value.toInt() + 1}/08';
                                      }
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(text, style: style),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text(
                                    'Form Scores',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(fontSize: 10, color: Colors.black);
                                      String text = '${value.toInt()}%';
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(text, style: style),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey, width: 2)
                              ),
                              minX: 0,
                              maxX: 14,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Weekly Challenges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Weekly Challenges', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    TextInWC(firstField: 'Newly Pose', secondField: '37'),
                    SizedBox(height: 10),
                    TextInWC(firstField: 'Highest Daily Streak', secondField: '108'),
                    SizedBox(height: 10),
                    TextInWC(firstField: 'Perfect Practice', secondField: '40'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      bottomNavigationBar: const bottom_bar(),
    );
  }
}

class StatsBox extends StatelessWidget {
  final Color? boxColor;
  final IconData? firstIcon;
  final String secondLine;
  final String thirdLine;
  final String fourthLine;
  
  const StatsBox({
    Key? key,
    required this.boxColor,
    required this.firstIcon,
    required this.secondLine,
    required this.thirdLine,
    required this.fourthLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      height: 180,
      width: 180,
      child: Column(
        children: [
          Icon(firstIcon, size: 55),
          const SizedBox(height: 5),
          Text(secondLine, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(thirdLine, style: const TextStyle(fontSize: 16)),
          Text(fourthLine, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class TextInWC extends StatelessWidget {
  final String firstField;
  final String secondField;
  const TextInWC({Key? key, required this.firstField, required this.secondField}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(firstField, style: const TextStyle(fontSize: 16)),
        Text(secondField, style: const TextStyle(color: Colors.green, fontSize: 16))
      ],
    );
  }
}