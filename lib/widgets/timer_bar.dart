import 'package:flutter/material.dart';
import '../models/timer_type.dart';
import '../models/app_skin.dart';
import '../themes/app_theme.dart';

class TimerBar extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final TimerType timerType;
  final AppSkin appSkin;
  final bool isVertical;
  final double segmentGap;
  final double barThickness;

  const TimerBar({
    super.key,
    required this.duration,
    this.onComplete,
    this.timerType = TimerType.smooth,
    this.appSkin = AppSkin.classic,
    this.isVertical = false,
    this.segmentGap = 2.0,
    this.barThickness = 8.0,
  });

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.timerType == TimerType.segmented) {
      _startSegmentedTimer();
    } else {
      _controller.forward();
    }
  }

  void _startSegmentedTimer() {
    // For segmented timer, update every second
    Future.doWhile(() async {
      if (!mounted || _remainingSeconds <= 0) return false;

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds <= 0) {
          widget.onComplete?.call();
          return false;
        }
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timerType == TimerType.segmented) {
      return _buildSegmentedTimer();
    } else {
      return _buildSmoothTimer();
    }
  }

  Widget _buildSmoothTimer() {
    final progressColor = SkinConfig.getProgressBarColor(widget.appSkin);
    final backgroundColor = SkinConfig.getProgressBarBackgroundColor(widget.appSkin);

    if (widget.isVertical) {
      return Container(
        width: widget.barThickness,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.barThickness / 2),
          color: backgroundColor,
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.barThickness / 2),
                    color: widget.appSkin == AppSkin.eink
                        ? progressColor
                        : _getProgressColorForValue(_animation.value),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        height: widget.barThickness,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.barThickness / 2),
          color: backgroundColor,
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.barThickness / 2),
                    color: widget.appSkin == AppSkin.eink
                        ? progressColor
                        : _getProgressColorForValue(_animation.value),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Color _getProgressColorForValue(double value) {
    if (widget.appSkin == AppSkin.eink) {
      return Colors.black;
    }

    if (value > 0.3) {
      return Colors.green;
    } else if (value > 0.1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildSegmentedTimer() {
    final totalSeconds = widget.duration.inSeconds;
    final segmentsFilled = _remainingSeconds;
    final backgroundColor = SkinConfig.getProgressBarBackgroundColor(widget.appSkin);
    final progress = segmentsFilled / totalSeconds;

    Color segmentColor;
    if (widget.appSkin == AppSkin.eink) {
      segmentColor = Colors.black;
    } else {
      if (progress > 0.3) {
        segmentColor = Colors.green;
      } else if (progress > 0.1) {
        segmentColor = Colors.orange;
      } else {
        segmentColor = Colors.red;
      }
    }

    if (widget.isVertical) {
      return Container(
        width: widget.barThickness,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.barThickness / 2),
          color: backgroundColor,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight - (widget.segmentGap * (totalSeconds - 1));
            final segmentHeight = availableHeight / totalSeconds;

            return Column(
              children: List.generate(totalSeconds, (index) {
                final isActive = (totalSeconds - 1 - index) < segmentsFilled;

                return Container(
                  width: widget.barThickness,
                  height: segmentHeight,
                  margin: EdgeInsets.only(
                    bottom: index < totalSeconds - 1 ? widget.segmentGap : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? Radius.circular(widget.barThickness / 2) : Radius.zero,
                      bottom: index == totalSeconds - 1 ? Radius.circular(widget.barThickness / 2) : Radius.zero,
                    ),
                    color: isActive ? segmentColor : Colors.transparent,
                  ),
                );
              }),
            );
          },
        ),
      );
    } else {
      return Container(
        height: widget.barThickness,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.barThickness / 2),
          color: backgroundColor,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - (widget.segmentGap * (totalSeconds - 1));
            final segmentWidth = availableWidth / totalSeconds;

            if (segmentWidth <= 0) {
              // Fallback to smooth timer if too many segments
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.barThickness / 2),
                  color: segmentColor,
                ),
                width: constraints.maxWidth * progress,
              );
            }

            return Row(
              children: List.generate(totalSeconds, (index) {
                final isActive = index < segmentsFilled;

                return Container(
                  width: segmentWidth,
                  height: widget.barThickness,
                  margin: EdgeInsets.only(
                    right: index < totalSeconds - 1 ? widget.segmentGap : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: index == 0 ? Radius.circular(widget.barThickness / 2) : Radius.zero,
                      right: index == totalSeconds - 1 ? Radius.circular(widget.barThickness / 2) : Radius.zero,
                    ),
                    color: isActive ? segmentColor : Colors.transparent,
                  ),
                );
              }),
            );
          },
        ),
      );
    }
  }
}