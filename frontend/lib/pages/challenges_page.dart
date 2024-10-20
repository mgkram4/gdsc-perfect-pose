import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/challenge_card.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: 'Challenges',
        onSettingsTap: () => showSettingsModal(context),
      ),
      bottomNavigationBar: const bottom_bar(),
      body: SafeArea(
        child: ListView(
            scrollDirection: Axis.vertical,
            addAutomaticKeepAlives: false,
            children: const [
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 30.0,
                  right: 30.0,
                  bottom: 8.0,
                ),
                child: ChallengeCard(
                  title: "Downward Dog",
                  description: "Do one Downward Dog",
                  typeOfChallenge: "New Pose!",
                  progress: 0.75,
                  done: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 30.0,
                  right: 30.0,
                  bottom: 8.0,
                ),
                child: ChallengeCard(
                  title: "Squats",
                  description: "Do 30 squats at least 80%",
                  typeOfChallenge: "Consistent Practice",
                  progress: 0.25,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 30.0,
                  right: 30.0,
                  bottom: 8.0,
                ),
                child: ChallengeCard(
                  title: "One Pose",
                  description: "Achieve One Perfect Pose",
                  typeOfChallenge: "Daily Challenge",
                  progress: 0.30,
                  done: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 30.0,
                  right: 30.0,
                  bottom: 8.0,
                ),
                child: ChallengeCard(
                  title: "Deadlift",
                  description: "Complete 10 Perfect Deadlifts",
                  typeOfChallenge: "Perfect Practice",
                  progress: 0.50,
                ),
              )
            ]),
      ),
    );
  }
}
