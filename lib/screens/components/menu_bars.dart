import 'dart:math' as math;

import 'package:flutter/material.dart';

class MenuBars extends StatefulWidget {
  final Color color;
  final double? lineHeight;
  final VoidCallback function;
  final double? lineWidth;
  const MenuBars(
      {Key? key,
      required this.color,
      this.lineHeight,
      this.lineWidth,
      required this.function})
      : super(key: key);

  @override
  _MenuBarsState createState() => _MenuBarsState();
}

class _MenuBarsState extends State<MenuBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.ease,
  );
  bool isOpen = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  toggleMenuBars() {
    if (isOpen) {
      print("Closed");
      setState(() {
        isOpen = false;
        _animationController.reverse();
      });
    } else {
      print("Opened");
      setState(() {
        isOpen = true;
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.function.call();
        toggleMenuBars();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: AnimatedBuilder(
          builder: (BuildContext context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(),
                Positioned(
                  top: (1 - _animation.value) * 15,
                  child: Opacity(
                    opacity: (1 - _animation.value),
                    child: buildContainerBar(),
                  ),
                ),
                Positioned(
                  bottom: (1 - _animation.value) * 15,
                  child: Opacity(
                    opacity: (1 - _animation.value),
                    child: buildContainerBar(),
                  ),
                ),
                Transform.rotate(
                  angle: (_animation.value) * math.pi / 4,
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: _animation.value,
                    child: buildContainerBar(),
                  ),
                ),
                Transform.rotate(
                  angle: (_animation.value) * -math.pi / 4,
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: _animation.value,
                    child: buildContainerBar(),
                  ),
                ),
              ],
            );
          },
          animation: _animationController,
        ),
      ),
    );
  }

  Container buildContainerBar() {
    return Container(
      height: widget.lineHeight ?? 4,
      width: widget.lineWidth ?? 26,
      decoration: BoxDecoration(
        color: widget.color,
      ),
    );
  }
}
