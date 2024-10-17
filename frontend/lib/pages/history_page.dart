import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedItem = "All Exercises";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: "History",
        onSettingsTap: () => showSettingsModal(context)
      ),
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          addAutomaticKeepAlives: false,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Filter By Text Container
                Container(
                  height: 45,
                  margin: EdgeInsets.only(
                    top: screenWidth * 0.0775,
                    right: screenWidth * 0.1,
                  ),
                  child: Text(
                    'Filter by:',
                    style: TextStyle(
                        fontSize: screenWidth * 0.0675,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // DropdownMenu
                Container(
                  alignment: Alignment.center,
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 223, 224, 224),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    iconSize: 30,
                    iconEnabledColor: Colors.black,
                    icon: const Icon(Icons.keyboard_arrow_down_sharp),
                    underline: Container(),
                    isExpanded: true,
                    value: _selectedItem,
                    items: [
                      // Replace with filters
                      _buildDropdownMenuItem(context, "All Exercises"),
                      _buildDropdownMenuItem(context, "Test 1"),
                      _buildDropdownMenuItem(context, "Freakbob"),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedItem = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),

            // Create Exercise containers
            _buildHistoryContainer(context, "Squat", "9/18/2024", 85),
            _buildHistoryContainer(context, "Plank", "9/14/2024", 78),
            _buildHistoryContainer(context, "Downward Dog", "9/13/2024", 67),
            _buildHistoryContainer(context, "Squat", "9/18/2024", 85),
            _buildHistoryContainer(context, "Plank", "9/14/2024", 78),
            _buildHistoryContainer(context, "Downward Dog", "9/13/2024", 67)
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 60,
        child: bottom_bar(),
      ),
    );
  }
}

// Helper method to create exercise containers with dynamic font sizing
Widget _buildHistoryContainer(
    BuildContext context, String exerciseName, String date, int score) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double fontSizeExercise = screenWidth * 0.0675;
  double fontSizeDate = screenWidth * 0.05;
  double fontSizeScore = screenWidth * 0.0515;
  double fontSizeViewDetails = screenWidth * 0.045;

  return Container(
    height: screenHeight * 0.18,
    margin: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.1,
      vertical: screenHeight * 0.01,
    ),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 5,
            color: const Color.fromARGB(255, 98, 97, 97).withOpacity(0.3),
          ),
        ]),
    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exerciseName,
              style: TextStyle(
                  fontSize: fontSizeExercise, fontWeight: FontWeight.bold),
            ),
            // The date
            Text(date,
                style: TextStyle(
                    fontSize: fontSizeDate,
                    color: const Color.fromARGB(255, 141, 141, 141))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Form score: $score/100",
              style: TextStyle(fontSize: fontSizeScore),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "View Details",
              style: TextStyle(
                  fontSize: fontSizeViewDetails,
                  color: const Color.fromARGB(255, 3, 123, 244)), //20
            ),
          ],
        ),
      ],
    ),
  );
}

// Helper method to create dropdown menu items with dynamic font sizing
DropdownMenuItem<String> _buildDropdownMenuItem(
    BuildContext context, String text) {
  double screenWidth = MediaQuery.of(context).size.width;
  return DropdownMenuItem(
    value: text,
    child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: screenWidth * 0.04),
        )),
  );
}
