import 'dart:async';
import 'package:flutter/material.dart';

import 'package:on_time_front/screens/preparation_done.dart';

import 'package:on_time_front/widgets/button.dart';
import 'package:on_time_front/widgets/preparation_step_list.dart';

import 'package:on_time_front/widgets/arc_painter_no_marker.dart';

class AlarmScreen extends StatefulWidget {
  final Map<String, dynamic> schedule; // 스케줄 데이터를 받음

  const AlarmScreen({
    super.key,
    required this.schedule,
  });

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late List<dynamic> preparations;
  late List<double> preparationRatios;
  late List<bool> preparationCompleted;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double currentProgress = 0.0; // 현재 진행률
  double targetProgress = 0.0; // 목표 진행률

  int currentIndex = 0;
  int remainingTime = 0;
  int totalPreparationTime = 0; // 전체 준비 시간의 초기값. 기준 용. 변하지 않음.
  int totalRemainingTime = 0; // 타이머 용 전체 준비 시간. 시간에 따라 차감

  // 준비과정 타이머
  Timer? preparationTimer;

  // 전체 시간 타이머
  Timer? fullTimeTimer;

  // 전체시간 = 약속시간 - (이동시간 + 여유시간 + 현재시간)
  late int fullTime;

  @override
  void initState() {
    super.initState();
    preparations = widget.schedule['preparations'];
    preparationRatios = [];
    preparationCompleted = List.filled(preparations.length, false);

    // 전체 준비시간 타이머 초기화
    initializeTotalTime();

    // FullTime 계산 초기화
    calculateFullTime();

    // 준비과정 시간 비율 계산
    calculatePreparationRatios();

    // AnimationController 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {
          currentProgress = _progressAnimation.value;
        });
      });

    // FullTime 타이머 시작
    startFullTimeTimer();

    // 첫 준비 과정 시작
    startPreparation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    preparationTimer?.cancel();
    fullTimeTimer?.cancel();
    super.dispose();
  }

  // 전체 준비 시간 초기화
  void initializeTotalTime() {
    totalPreparationTime = preparations.fold<int>(
      0,
      (sum, prep) => sum + (prep['preparationTime'] as int) * 60,
    );
    totalRemainingTime = totalPreparationTime; // 초기 전체 시간 설정
  }

  // Fulltime 계산
  void calculateFullTime() {
    final DateTime now = DateTime.now();
    final DateTime scheduleTime =
        DateTime.parse(widget.schedule['scheduleTime']);
    final String moveTimeString = widget.schedule['moveTime'];

    final List<String> moveTimeParts = moveTimeString.split(':');
    final Duration moveTime = Duration(
      hours: int.parse(moveTimeParts[0]),
      minutes: int.parse(moveTimeParts[1]),
      seconds: int.parse(moveTimeParts[2]),
    );

    final Duration spareTime =
        Duration(minutes: widget.schedule['scheduleSpareTime']);

    final Duration remainingDuration =
        scheduleTime.difference(now) - moveTime - spareTime;

    if (remainingDuration.isNegative) {
      fullTime = 0; // 이미 시간이 지난 경우 0초로 설정
    } else {
      fullTime = remainingDuration.inSeconds; // 남은 시간을 초 단위로 저장
    }
  }

  void calculatePreparationRatios() {
    int cumulativeTime = 0;
    for (var preparation in preparations) {
      final int prepTime = preparation['preparationTime'] * 60;
      preparationRatios.add(cumulativeTime / totalPreparationTime);
      cumulativeTime += prepTime;
    }
  }

  // 진행률 애니메이션 갱신
  void updateProgress(double newProgress) {
    _progressAnimation = Tween<double>(
      begin: currentProgress, // 현재 진행 상태에서 시작
      end: newProgress, // 다음 목표 진행 상태로 끝
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController
      ..reset()
      ..forward().then((_) {
        setState(() {
          currentProgress = newProgress;
        });
      });
  }

  // 전체 시간 타이머
  void startFullTimeTimer() {
    fullTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (fullTime > 0) {
        setState(() {
          fullTime--;
        });
      } else {
        timer.cancel();
        navigateToPreparationDone();
      }
    });
  }

  // 준비 과정 시작
  void startPreparation() {
    if (currentIndex < preparations.length) {
      setState(() {
        remainingTime = preparations[currentIndex]['preparationTime'] * 60;
      });

      // 타이머 시작
      preparationTimer =
          Timer.periodic(const Duration(seconds: 1), (preparationTimer) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
            totalRemainingTime--;
            updateProgress(1.0 - (totalRemainingTime / totalPreparationTime));
          });
        } else {
          preparationTimer.cancel(); // 타이머 종료
          preparationCompleted[currentIndex] = true; // 해당 준비 과정 완료 표시
          moveToNextPreparation(); // 다음 준비 과정으로 이동
        }
      });
    } else {
      // 준비과정이 모두 끝난 경우
      navigateToPreparationDone();
    }
  }

  // 건너뛰기
  void skipCurrentPreparation() {
    preparationTimer?.cancel();

    if (currentIndex < preparations.length) {
      // 현재 남아있는 시간을 총 남은 시간에서 차감
      setState(
        () {
          totalRemainingTime -= remainingTime;
          preparationCompleted[currentIndex] = true;
          remainingTime = 0;
          updateProgress(1.0 - (totalRemainingTime / totalPreparationTime));
        },
      );

      moveToNextPreparation();
    }
  }

  void moveToNextPreparation() {
    preparationTimer?.cancel();

    if (currentIndex + 1 < preparations.length) {
      setState(() {
        currentIndex++;
      });

      // 다음 준비 과정 시작
      startPreparation();
    } else {
      navigateToPreparationDone();
    }
  }

  void navigateToPreparationDone() {
    preparationTimer?.cancel(); // 타이머 종료
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PreparationDone()),
    );
  }

  // 준비과정 남은 시간 표시
  String formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return minutes > 0 ? '$hours시간 $minutes분' : '$hours시간';
    } else if (minutes > 0) {
      return remainingSeconds > 0
          ? '$minutes분 $remainingSeconds초'
          : '$minutes분';
    } else if (seconds <= 0) {
      return '0초';
    } else {
      return '$remainingSeconds초';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPreparation = preparations[currentIndex];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '준비중',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            onPressed: () {
              preparationTimer?.cancel();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '${formatTime(fullTime)} 뒤에', // 총 준비 시간 표시
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    '밖으로 나가야 해요',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 190, // 호의 전체 높이를 조정
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 타이머 그래프
                CustomPaint(
                  size: const Size(200, 100), // 호의 크기 조정
                  painter: ArcPainterNoMarker(
                    progress: currentProgress,
                    preparationRatios: preparationRatios,
                    preparationCompleted: preparationCompleted,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentPreparation['preparationName'], // 준비 과정 이름
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatTime(remainingTime), // 남은 시간 표시
                        style: const TextStyle(
                          fontSize: 30,
                          color: Color(0xff5C79FB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '남음',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Button(
                  width: 100,
                  height: 40,
                  text: '건너뛰기',
                  onPressed: skipCurrentPreparation,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                  ),
                  // 준비과정 목록 표시
                  child: SizedBox(
                    height: 181,
                    width: 358,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PreparationStepList(
                        preparations: preparations,
                        currentIndex: currentIndex,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Button(
                  text: '종료하기',
                  onPressed: () {
                    navigateToPreparationDone();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
