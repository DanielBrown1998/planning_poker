import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planning_poker/ui/components/app_bar_planning_poker.dart';
import 'package:planning_poker/ui/state/home_state.dart';
import 'package:planning_poker/utils/helpers/sizes_window.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final duration = const Duration(milliseconds: 400);
  late final CarouselSliderController _carouselController;
  late final AnimationController _animationController;
  late final HomeState homeState;

  @override
  void initState() {
    super.initState();
    // Initialize CarouselController and AnimationController
    _carouselController = CarouselSliderController();
    _animationController = AnimationController(vsync: this, duration: duration);

    // Initialize HomeState
    homeState = context.read<HomeState>();
    // Listen to changes in HomeState
    homeState.addListener(() {
      setState(() {});
    });
    // Add WidgetsBinding observer
    WidgetsBinding.instance.addObserver(this);
    // Animate opacityText after a short delay
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    homeState.removeListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    homeState.resetState();
    // ignore: invalid_use_of_protected_member
    if (!homeState.hasListeners) {
      homeState.addListener(() => setState(() {}));
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final appBarHeight = size.height * 0.2;
    // final widthWindowIsLarge = isLargeWindow(size.width);
    // final widthWindowIsMedium = isMediumWindow(size.width);
    final sizeWindow = getSizeWindow(size.width);
    return Scaffold(
      appBar: AppBarPlanningPoker(
        title: FittedBox(
          fit: BoxFit.fill,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 42,
              color: Colors.white70,
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            ),
          ),
        ),
        colorBase: homeState.colorBase,
        animationController: _animationController,
        height: appBarHeight,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: duration,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        homeState.colorBase.withAlpha(20),
                        homeState.colorBase.withAlpha(50),
                        homeState.colorBase.withAlpha(130),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.directional(
                textDirection: TextDirection.ltr,
                width: size.width,
                height: size.height * .15,
                top: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: duration,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset.zero,
                              end: const Offset(0.0, 0.5),
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          homeState.actualDescriptionCard,
                          //to ensure the AnimatedSwitcher detects changes
                          key: ValueKey<String>(
                            homeState.actualDescriptionCard,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: homeState.colorBase,
                            fontFamily: GoogleFonts.rubik().fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36.0),

                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        color: homeState.colorBase,
                        size: 35,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: isTall(size.height)
                              ? 240
                              : (isMedium(size.height) ? 200 : 160),
                        ),
                        child: CarouselSlider(
                          key: ValueKey<String>('carousel_cards'),
                          items: List.generate(homeState.valueCards.length, (
                            index,
                          ) {
                            return homeState.cardsPoker[index];
                          }),
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: size.height * 0.625,
                            animateToClosest: true,
                            enlargeCenterPage: sizeWindow == SizeWindow.large
                                ? false
                                : true,
                            enableInfiniteScroll: true,
                            initialPage: 0,
                            viewportFraction: sizeWindow == SizeWindow.large
                                ? .11
                                : (sizeWindow == SizeWindow.medium ? .2 : .35),
                            aspectRatio: 1 / (size.height / size.width),
                            scrollDirection: Axis.horizontal,
                            scrollPhysics: const BouncingScrollPhysics(),
                            autoPlay: false,
                            onPageChanged: (index, reason) {
                              homeState.flipCardAtIndex(
                                index,
                                homeState.choicedTime,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
