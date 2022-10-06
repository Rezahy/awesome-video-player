import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/widgets/video_control_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset('assets/videos/pizza.mp4');

  bool isShowingVideoControlPanel = false;
  bool isShowingVolumeControlPanel = false;
  Timer? controlPanelTimer;
  Timer? volumeControlPanelTime;

  @override
  void initState() {
    //initialize video player
    videoPlayerController
      ..initialize()
      ..setLooping(true)
      ..setVolume(0.5)
      ..addListener(() {
        setState(() {});
      })
      ..play();

    //listen to changing volume device
    super.initState();
  }

  void initVolumeControlTimer() {
    volumeControlPanelTime?.cancel();
    volumeControlPanelTime = Timer(const Duration(seconds: 3), () {
      setState(() {
        isShowingVolumeControlPanel = false;
      });
    });
  }

  void initControlPanelTimer() {
    controlPanelTimer?.cancel();
    controlPanelTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        isShowingVideoControlPanel = false;
      });
    });
  }

  void increaseVideoVolume(double newVolumeValue) {
    videoPlayerController.setVolume(newVolumeValue);
  }

  void decreaseVideoVolume(double newVolumeValue) {
    // PerfectVolumeControl.setVolume(newVolumeValue);
    videoPlayerController.setVolume(newVolumeValue);
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Swiping in right direction.
    if (details.delta.dx > 0) {
      var dx = details.delta.dx;
      if (!isShowingVideoControlPanel) {
        setState(() {
          isShowingVideoControlPanel = true;
        });
      }
      //checking if the increase position is more than position of the video
      var currentPosition = videoPlayerController.value.position.inMilliseconds;
      var maximumPosition = videoPlayerController.value.duration.inMilliseconds;
      var changedPosition =
          Duration(milliseconds: currentPosition + (dx * 150).toInt());
      if (changedPosition.inMilliseconds <= maximumPosition) {
        videoPlayerController.seekTo(changedPosition);
      } else {
        videoPlayerController.seekTo(Duration(milliseconds: maximumPosition));
      }
    }

    // Swiping in left direction.
    if (details.delta.dx < 0) {
      var dx = details.delta.dx;
      if (!isShowingVideoControlPanel) {
        setState(() {
          isShowingVideoControlPanel = true;
        });
      }
      //checking if the decrease position is lower than 0
      var currentPosition = videoPlayerController.value.position.inMilliseconds;
      var changedPosition =
          Duration(milliseconds: currentPosition + (dx * 150).toInt());
      if (changedPosition.inMilliseconds >= 0) {
        videoPlayerController.seekTo(changedPosition);
      } else {
        videoPlayerController.seekTo(const Duration(milliseconds: 0));
      }
    }
    initControlPanelTimer();
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    var dy = details.delta.dy;
    var currentVideoPlayerVolume = videoPlayerController.value.volume;
    // Swiping in top direction.
    if (dy < 0) {
      double newVolumeValue = currentVideoPlayerVolume + 0.008;
      if (newVolumeValue <= 1) {
        increaseVideoVolume(newVolumeValue);
      } else {
        increaseVideoVolume(1);
      }
    }
    // Swiping in bottom direction.
    if (dy > 0) {
      double newVolumeValue = currentVideoPlayerVolume - 0.008;
      if (newVolumeValue >= 0) {
        increaseVideoVolume(newVolumeValue);
      } else {
        increaseVideoVolume(0);
      }
    }
    if (!isShowingVolumeControlPanel) {
      setState(() {
        isShowingVolumeControlPanel = true;
      });
      initVolumeControlTimer();
    }
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    controlPanelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                var dy = details.delta.dy;
                var currentVideoPlayerVolume =
                    videoPlayerController.value.volume;
                // Swiping in top direction.
                if (dy < 0) {
                  double newVolumeValue = currentVideoPlayerVolume + 0.0065;
                  if (newVolumeValue <= 1) {
                    increaseVideoVolume(newVolumeValue);
                  } else {
                    increaseVideoVolume(1);
                  }
                }
                // Swiping in bottom direction.
                if (dy > 0) {
                  double newVolumeValue = currentVideoPlayerVolume - 0.0065;
                  if (newVolumeValue >= 0) {
                    increaseVideoVolume(newVolumeValue);
                  } else {
                    increaseVideoVolume(0);
                  }
                }
                if (!isShowingVolumeControlPanel) {
                  setState(() {
                    isShowingVolumeControlPanel = true;
                  });
                  initVolumeControlTimer();
                }
              },
              onPanUpdate: onPanUpdate,
              onTap: () {
                if (!isShowingVideoControlPanel) {
                  setState(() {
                    isShowingVideoControlPanel = true;
                  });
                  initControlPanelTimer();
                }
              },
              child: VideoPlayer(videoPlayerController),
            ),
          ),
          if (isShowingVideoControlPanel)
            VideoControlPanel(
                videoPlayerController: videoPlayerController,
                gestureTapCallback: () {
                  setState(() {
                    isShowingVideoControlPanel = false;
                  });
                  controlPanelTimer?.cancel();
                },
                gesturePanUpdateCallback: onPanUpdate,
                initControlPanelTimer: initControlPanelTimer,
                gestureVerticalDragUpdate: onVerticalDragUpdate),
          if (isShowingVolumeControlPanel)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.speaker_2,
                      color: Colors.white,
                      size: 45,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      (videoPlayerController.value.volume * 100)
                          .toStringAsFixed(0),
                      style: GoogleFonts.lato(
                          fontSize: 65,
                          color: Colors.white,
                          fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
