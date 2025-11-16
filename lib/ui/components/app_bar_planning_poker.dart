import 'package:flutter/material.dart';
// import 'package:planning_poker/ui/components/lottie.dart';
import 'package:planning_poker/ui/state/home_state.dart';
import 'package:provider/provider.dart';

class AppBarPlanningPoker extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final Color colorBase;
  final double height;
  final AnimationController animationController;
  const AppBarPlanningPoker({
    super.key,
    required this.title,
    required this.colorBase,
    required this.animationController,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
      color: colorBase,
      child: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Consumer<HomeState>(
            builder: (context, homeState, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Flexible(
                  //   flex: 2,
                  //   child: LottieCard(controller: animationController),
                  // ),
                  Flexible(
                    flex: 8,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: title ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
