import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import 'custom_track_shape.dart';

class VideoControlPanel extends StatefulWidget {
  const VideoControlPanel(
      {Key? key,
      required this.videoPlayerController,
      required this.gestureTapCallback,
      required this.initControlPanelTimer,
      required this.gesturePanUpdateCallback,
      this.gestureVerticalDragUpdate})
      : super(key: key);
  final VideoPlayerController videoPlayerController;
  final GestureTapCallback gestureTapCallback;
  final GestureDragUpdateCallback gesturePanUpdateCallback;
  final GestureDragUpdateCallback? gestureVerticalDragUpdate;

  final VoidCallback initControlPanelTimer;

  @override
  State<VideoControlPanel> createState() => _VideoControlPanelState();
}

class _VideoControlPanelState extends State<VideoControlPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> animation;
  late final VideoPlayerController videoPlayerController;
  final Duration profileOpacityDuration = const Duration(
    milliseconds: 400,
  );
  double profileOpacity = 0.0;
  final Duration containerOpacityDuration = const Duration(milliseconds: 100);
  double containerOpacity = 0.0;

  //fade animation
  late final AnimationController fadeAnimationController;
  late final Animation<double> fadeAnimation;
  @override
  void initState() {
    fadeAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(fadeAnimationController);
    fadeAnimationController.forward();

    videoPlayerController = widget.videoPlayerController;
    Future.delayed(containerOpacityDuration, () {
      setState(() {
        containerOpacity = 1.0;
      });
    });
    Future.delayed(profileOpacityDuration, () {
      setState(() {
        profileOpacity = 0.7;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.gestureTapCallback,
        onPanUpdate: widget.gesturePanUpdateCallback,
        onVerticalDragUpdate: widget.gestureVerticalDragUpdate,
        child: AnimatedOpacity(
          opacity: containerOpacity,
          duration: containerOpacityDuration,
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 48, right: 16, bottom: 30),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      opacity: profileOpacity,
                      duration: profileOpacityDuration,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 0.8,
                                  color: Colors.white.withOpacity(0.5)),
                              image: const DecorationImage(
                                  image: AssetImage('assets/images/pizza.jpg'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Golden Pizza',
                                style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                '@golden_pizza',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                trackShape: CustomTrackShape(),
                                // overlayShape: SliderComponentShape.noOverlay),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 15)),
                            child: Slider(
                              inactiveColor: Colors.white12,
                              activeColor: Colors.white,
                              max: videoPlayerController
                                      .value.duration.inMilliseconds
                                      .toDouble() +
                                  100,
                              min: 0,
                              value: videoPlayerController
                                  .value.position.inMilliseconds
                                  .toDouble(),
                              onChanged: (newValue) {
                                videoPlayerController.seekTo(
                                    Duration(milliseconds: newValue.toInt()));
                              },
                              onChangeStart: (value) {
                                widget.initControlPanelTimer();
                                videoPlayerController.pause();
                              },
                              onChangeEnd: (value) {
                                widget.initControlPanelTimer();
                                videoPlayerController.play();
                              },
                            ),
                          ),
                        ),
                        // VideoProgressIndicator(
                        //   widget.videoPlayerController,
                        //   allowScrubbing: true,
                        //   colors: VideoProgressColors(
                        //     playedColor: Colors.white,
                        //     backgroundColor: Colors.white.withOpacity(0.3),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              videoPlayerController.value.position
                                  .toMinutesSecond(),
                              // style:
                              //     TextStyle(color: Colors.white, fontSize: 12),
                              style: GoogleFonts.lato(
                                  color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              videoPlayerController.value.duration
                                  .toMinutesSecond(),
                              // style:
                              //     TextStyle(color: Colors.white, fontSize: 12),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                var currentPosition = videoPlayerController
                                    .value.position.inMilliseconds;
                                videoPlayerController.seekTo(Duration(
                                    milliseconds: currentPosition - 5000));
                                widget.initControlPanelTimer();
                              },
                              icon: const Icon(
                                  CupertinoIcons.backward_end_alt_fill),
                              color: Colors.white,
                              iconSize: 24,
                            ),
                            IconButton(
                              onPressed: () {
                                widget.initControlPanelTimer();
                                if (widget
                                    .videoPlayerController.value.isPlaying) {
                                  setState(() {
                                    widget.videoPlayerController.pause();
                                  });
                                } else {
                                  setState(() {
                                    widget.videoPlayerController.play();
                                  });
                                }
                              },
                              icon: Icon(
                                  widget.videoPlayerController.value.isPlaying
                                      ? CupertinoIcons.pause_circle_fill
                                      : CupertinoIcons.play_circle_fill),
                              color: Colors.white,
                              iconSize: 63,
                            ),
                            IconButton(
                              onPressed: () {
                                var currentPosition = videoPlayerController
                                    .value.position.inMilliseconds;
                                videoPlayerController.seekTo(Duration(
                                    milliseconds: currentPosition + 5000));
                                widget.initControlPanelTimer();
                              },
                              icon: const Icon(
                                  CupertinoIcons.forward_end_alt_fill),
                              color: Colors.white,
                              iconSize: 24,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension DurationExtensions on Duration {
//  converts the duration into a readable string
//05:15
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return '${_toTwoDigits(inHours)}:$twoDigitMinutes}';
  }

  //  converts the duration into a readable string
//05:15:10

  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSecond = _toTwoDigits(inSeconds.remainder(60));

    return '${_toTwoDigits(inHours)}:$twoDigitMinutes:$twoDigitSecond';
  }

  String toMinutesSecond() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  String _toTwoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }
}
